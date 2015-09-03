# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hydraulic_brake"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Stephen Crosby"]
  s.date = "2015-09-03"
  s.description = "Sends notifications to an Airbrake server"
  s.email = "stevecrozz@gmail.com"
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = %w(
    .gitignore
    .rvmrc
    .travis.yml
    .yardopts
    Gemfile
    INSTALL
    MIT-LICENSE
    README.md
    Rakefile
    VERSION
    hydraulic_brake.gemspec
    lib/hydraulic_brake.rb
    lib/hydraulic_brake/async_sender.rb
    lib/hydraulic_brake/backtrace.rb
    lib/hydraulic_brake/configuration.rb
    lib/hydraulic_brake/notice.rb
    lib/hydraulic_brake/sender.rb
    lib/hydraulic_brake/test_notification.rb
    lib/hydraulic_brake/version.rb
    resources/README.md
    resources/ca-bundle.crt
    script/notify_integration_test.rb
    test/airbrake_2_3.xsd
    test/async_sender_test.rb
    test/backtrace_test.rb
    test/configuration_test.rb
    test/helper.rb
    test/logger_test.rb
    test/notice_test.rb
    test/notifier_test.rb
    test/recursion_test.rb
    test/sender_test.rb
  )
  s.homepage = "http://github.com/stevecrozz/hydraulic_brake"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Simple Airbrake client"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_development_dependency(%q<bourne>, ["~> 1.5.0"])
      s.add_development_dependency(%q<fakeweb>, ["~> 1.3.0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<nokogiri>, ["~> 1.4.3.1"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<bourne>, ["~> 1.5.0"])
      s.add_dependency(%q<fakeweb>, ["~> 1.3.0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<nokogiri>, ["~> 1.4.3.1"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<bourne>, ["~> 1.5.0"])
    s.add_dependency(%q<fakeweb>, ["~> 1.3.0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<nokogiri>, ["~> 1.4.3.1"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

