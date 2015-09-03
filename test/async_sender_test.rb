require File.expand_path '../helper', __FILE__

class AsyncSenderTest < Test::Unit::TestCase
  def setup
    reset_config
  end

  def build_sync_sender
    klass = Class.new do
      attr_reader :notices_sent

      def send_to_airbrake(notice)
        @notices_sent ||= []
        @notices_sent.push notice
      end
    end

    klass.new
  end

  def build_sender(opts = {})
    HydraulicBrake::AsyncSender.new(
      :sync_sender => build_sync_sender,
      :capacity => 5)
  end

  def build_notice
    HydraulicBrake::Notice.new(
      :error_class => "FooBar", :error_message => "Foo Bar")
  end

  def wait_for_thread(thread)
    # wait for the sending thread to stop running
    while thread.status == 'run'
      sleep 0.01
    end
  end

  def mock_logger
    logger_class = Class.new do
      attr_reader :errors

      def error(blob)
        @errors ||= []
        @errors.push(blob)
      end

      def debug(blob); end
    end

    logger_class.new
  end

  should "send a notice" do
    notice = build_notice
    sender = build_sender

    sender.send_to_airbrake(notice)
    wait_for_thread(sender.thread)

    notices_sent = sender.sync_sender.notices_sent
    assert notices_sent == [ notice ]
  end

  should "send multiple notices" do
    notice1 = build_notice
    notice2 = build_notice
    notice3 = build_notice
    sender = build_sender

    sender.send_to_airbrake(notice1)
    sender.send_to_airbrake(notice2)
    sender.send_to_airbrake(notice3)

    wait_for_thread(sender.thread)

    notices_sent = sender.sync_sender.notices_sent
    assert notices_sent == [ notice1, notice2, notice3 ]
  end

  should "reach capacity and stop accepting notices" do
    logger = mock_logger

    HydraulicBrake.configure do |c|
      c.logger = logger
    end

    notices = (1..100).map { build_notice }
    sender = build_sender

    notices.each { |n| sender.send_to_airbrake n }
    wait_for_thread(sender.thread)
    notices_sent = sender.sync_sender.notices_sent

    assert(
      notices_sent[0, 5] == notices[0, 5],
      'at least the first five errors should be delivered')
    assert(
      notices_sent.size < 100,
      'less than all the errors should be delivered')
    assert(
      logger.errors.size == notices.size - notices_sent.size,
      'for every error that was not delivered, an error should be logged')
  end
end
