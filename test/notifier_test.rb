require File.expand_path '../helper', __FILE__

class NotifierTest < Test::Unit::TestCase

  class OriginalException < Exception
  end

  class ContinuedException < Exception
  end

  include DefinesConstants

  def setup
    super
    reset_config
  end

  def assert_sent(notice, notice_args)
    assert_received(HydraulicBrake::Notice, :new) {|expect| expect.with(has_entries(notice_args)) }
    assert_received(HydraulicBrake.sender, :send_to_airbrake) {|expect| expect.with(notice) }
  end

  def set_public_env
    HydraulicBrake.configure { |config| config.environment_name = 'production' }
  end

  def set_development_env
    HydraulicBrake.configure { |config| config.environment_name = 'development' }
  end

  should "yield and save a configuration when configuring" do
    yielded_configuration = nil
    HydraulicBrake.configure do |config|
      yielded_configuration = config
    end

    assert_kind_of HydraulicBrake::Configuration, yielded_configuration
    assert_equal yielded_configuration, HydraulicBrake.configuration
  end

  should "not remove existing config options when configuring twice" do
    first_config = nil
    HydraulicBrake.configure do |config|
      first_config = config
    end
    HydraulicBrake.configure do |config|
      assert_equal first_config, config
    end
  end

  should "configure the sender" do
    sender = stub_sender
    HydraulicBrake::Sender.stubs(:new => sender)
    configuration = nil

    HydraulicBrake.configure { |yielded_config| configuration = yielded_config }

    assert_received(HydraulicBrake::Sender, :new) { |expect| expect.with(configuration) }
    assert_equal sender, HydraulicBrake.sender
  end

  should "create and send a notice for an exception" do
    set_public_env
    exception = build_exception
    stub_sender!
    notice = stub_notice!

    HydraulicBrake.notify(exception)

    assert_sent notice, :exception => exception
  end

  should "create and send a notice for a hash" do
    set_public_env
    notice = stub_notice!
    notice_args = { :error_message => 'uh oh' }
    stub_sender!

    HydraulicBrake.notify(notice_args)

    assert_sent(notice, notice_args)
  end

  should "not pass the hash as an exception when sending a notice for it" do
    set_public_env
    notice = stub_notice!
    notice_args = { :error_message => 'uh oh' }
    stub_sender!

    HydraulicBrake.notify(notice_args)

    assert_received(HydraulicBrake::Notice, :new) {|expect| expect.with(Not(has_key(:exception))) }
  end

  should "create and send a notice for an exception that responds to to_hash" do
    set_public_env
    exception = build_exception
    notice = stub_notice!
    notice_args = { :error_message => 'uh oh' }
    exception.stubs(:to_hash).returns(notice_args)
    stub_sender!

    HydraulicBrake.notify(exception)

    assert_sent(notice, notice_args.merge(:exception => exception))
  end

  should "create and sent a notice for an exception and hash" do
    set_public_env
    exception = build_exception
    notice = stub_notice!
    notice_args = { :error_message => 'uh oh' }
    stub_sender!

    HydraulicBrake.notify(exception, notice_args)

    assert_sent(notice, notice_args.merge(:exception => exception))
  end

  should "not create a notice in a development environment" do
    set_development_env
    sender = stub_sender!

    HydraulicBrake.notify(build_exception)
    HydraulicBrake.notify_or_ignore(build_exception)

    assert_received(sender, :send_to_airbrake) {|expect| expect.never }
  end

  should "not deliver an ignored exception when notifying implicitly" do
    set_public_env
    exception = build_exception
    sender = stub_sender!
    notice = stub_notice!
    notice.stubs(:ignore? => true)

    HydraulicBrake.notify_or_ignore(exception)

    assert_received(sender, :send_to_airbrake) {|expect| expect.never }
  end

  should "deliver exception in async-mode" do
    HydraulicBrake.configure do |config|
      config.environment_name = 'production'
      config.async do |notice|
        HydraulicBrake.sender.send_to_airbrake(notice)
      end
    end
    exception = build_exception
    sender = stub_sender!
    notice = stub_notice!

    HydraulicBrake.notify(exception)

    assert_sent(notice, :exception => exception)
  end

  should "pass notice in async-mode" do
    received_notice = nil
    HydraulicBrake.configure do |config|
      config.environment_name = 'production'
      config.async {|notice| received_notice = notice}
    end
    exception = build_exception
    sender = stub_sender!
    notice = stub_notice!

    HydraulicBrake.notify(exception)

    assert_equal received_notice, notice
  end

  should "deliver an ignored exception when notifying manually" do
    set_public_env
    exception = build_exception
    sender = stub_sender!
    notice = stub_notice!
    notice.stubs(:ignore? => true)

    HydraulicBrake.notify(exception)

    assert_sent(notice, :exception => exception)
  end

  should "pass config to created notices" do
    exception = build_exception
    config_opts = { 'one' => 'two', 'three' => 'four' }
    notice = stub_notice!
    stub_sender!
    HydraulicBrake.configuration = stub('config', :merge => config_opts, :public? => true,:async? => nil)

    HydraulicBrake.notify(exception)

    assert_received(HydraulicBrake::Notice, :new) do |expect|
      expect.with(has_entries(config_opts))
    end
  end

  context "building notice JSON for an exception" do
    setup do
      @params    = { :controller => "users", :action => "create" }
      @exception = build_exception
      @hash      = HydraulicBrake.build_lookup_hash_for(@exception, @params)
    end

    should "set action" do
      assert_equal @params[:action], @hash[:action]
    end

    should "set controller" do
      assert_equal @params[:controller], @hash[:component]
    end

    should "set line number" do
      assert @hash[:line_number] =~ /\d+/
    end

    should "set file" do
      assert_match /test\/helper\.rb$/, @hash[:file]
    end

    should "set env to production" do
      assert_equal 'production', @hash[:environment_name]
    end

    should "set error class" do
      assert_equal @exception.class.to_s, @hash[:error_class]
    end

    should "not set file or line number with no backtrace" do
      @exception.stubs(:backtrace).returns([])

      @hash = HydraulicBrake.build_lookup_hash_for(@exception)

      assert_nil @hash[:line_number]
      assert_nil @hash[:file]
    end

    should "not set action or controller when not provided" do
      @hash = HydraulicBrake.build_lookup_hash_for(@exception)

      assert_nil @hash[:action]
      assert_nil @hash[:controller]
    end

    context "when an exception that provides #original_exception is raised" do
      setup do
        @exception.stubs(:original_exception).returns(begin
          raise NotifierTest::OriginalException.new
        rescue Exception => e
          e
        end)
      end

      should "unwrap exceptions that provide #original_exception" do
        @hash = HydraulicBrake.build_lookup_hash_for(@exception)
        assert_equal "NotifierTest::OriginalException", @hash[:error_class]
      end
    end

    context "when an exception that provides #continued_exception is raised" do
      setup do
        @exception.stubs(:continued_exception).returns(begin
          raise NotifierTest::ContinuedException.new
        rescue Exception => e
          e
        end)
      end

      should "unwrap exceptions that provide #continued_exception" do
        @hash = HydraulicBrake.build_lookup_hash_for(@exception)
        assert_equal "NotifierTest::ContinuedException", @hash[:error_class]
      end
    end
  end
end
