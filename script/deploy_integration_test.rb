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

HydraulicBrake::Hook.deploy({
  :api_key => ARGV.first,
  :scm_revision => "cd6b969f66ad0794c7117d5030f926b49f82b038",
  :scm_repository => "stevecrozz/hydraulic_brake",
  :local_username => "stevecrozz",
  :rails_env => "production", # everything is rails, right?
  :message => "Another deployment hook brought to you by HydraulicBrake"
})
