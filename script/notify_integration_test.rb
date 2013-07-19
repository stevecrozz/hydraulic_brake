#!/usr/bin/env ruby

$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'hydraulic_brake'

fail "Please supply an API Key as the first argument" if ARGV.empty?

host = ARGV[1]

secure = (ARGV[2] == "secure")

HydraulicBrake.configure do |config|
  config.secure  = secure
  config.host    = host
  config.api_key = ARGV.first
end

HydraulicBrake::TestNotification.send

