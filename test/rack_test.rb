require File.expand_path '../helper', __FILE__

class RackTest < Test::Unit::TestCase

  should "call the upstream app with the environment" do
    environment = { 'key' => 'value' }
    app = lambda { |env| ['response', {}, env] }
    stack = HydraulicBrake::Rack.new(app)

    response = stack.call(environment)

    assert_equal ['response', {}, environment], response
  end

  should "deliver an exception raised while calling an upstream app" do
    HydraulicBrake.stubs(:notify_or_ignore)

    exception = build_exception
    environment = { 'key' => 'value' }
    app = lambda do |env|
      raise exception
    end

    begin
      stack = HydraulicBrake::Rack.new(app)
      stack.call(environment)
    rescue Exception => raised
      assert_equal exception, raised
    else
      flunk "Didn't raise an exception"
    end

    assert_received(HydraulicBrake, :notify_or_ignore) do |expect|
      expect.with(exception, :rack_env => environment)
    end
  end

  should "deliver an exception in rack.exception" do
    HydraulicBrake.stubs(:notify_or_ignore)
    exception = build_exception
    environment = { 'key' => 'value' }

    response = [200, {}, ['okay']]
    app = lambda do |env|
      env['rack.exception'] = exception
      response
    end
    stack = HydraulicBrake::Rack.new(app)

    actual_response = stack.call(environment)

    assert_equal response, actual_response
    assert_received(HydraulicBrake, :notify_or_ignore) do |expect|
      expect.with(exception, :rack_env => environment)
    end
  end

end
