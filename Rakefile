# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "hydraulic_brake"
  gem.homepage = "http://github.com/stevecrozz/hydraulic_brake"
  gem.license = "MIT"
  gem.summary = "Simple Airbrake client"
  gem.description = %Q{Sends notifications to an Airbrake server}
  gem.email = "stevecrozz@gmail.com"
  gem.authors = ["Stephen Crosby"]
  gem.require_paths = ["lib"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/*_test.rb'
  test.verbose = true
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end

task :default => :test
