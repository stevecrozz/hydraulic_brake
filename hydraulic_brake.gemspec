# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hydraulic_brake/version"

Gem::Specification.new do |s|
  s.name        = %q{hydraulic_brake}
  s.version     = HydraulicBrake::VERSION.dup
  s.summary     = %q{Send your application errors to Airbrake}

  s.require_paths = ["lib"]
  s.files         = Dir["{generators/**/*,lib/**/*,resources/*,script/*}"]  +
    %w(hydraulic_brake.gemspec Gemfile Guardfile INSTALL MIT-LICENSE Rakefile README.md install.rb)
  s.test_files    = Dir.glob("{test,spec,features}/**/*")

  s.add_runtime_dependency("builder")
  s.add_runtime_dependency("girl_friday")

  s.add_development_dependency("actionpack",    "~> 2.3.8")
  s.add_development_dependency("activerecord",  "~> 2.3.8")
  s.add_development_dependency("activesupport", "~> 2.3.8")
  s.add_development_dependency("mocha",           "0.10.5")
  s.add_development_dependency("bourne",          ">= 1.0")
  s.add_development_dependency("cucumber",     "~> 0.10.6")
  s.add_development_dependency("fakeweb",       "~> 1.3.0")
  s.add_development_dependency("nokogiri",    "~> 1.4.3.1")
  s.add_development_dependency("rspec",         "~> 2.6.0")
  s.add_development_dependency("sham_rack",     "~> 1.3.0")
  s.add_development_dependency("shoulda",      "~> 2.11.3")
  s.add_development_dependency("capistrano",    "~> 2.8.0")
  s.add_development_dependency("guard"                    )
  s.add_development_dependency("guard-test"               )
  s.add_development_dependency("simplecov"                )

  s.authors = ["Stephen Crosby"]
  s.email   = %q{stevecrozz@gmail.com}
  s.homepage = "http://github.com/stevecrozz/hydraulic_brake"

  s.platform = Gem::Platform::RUBY
end
