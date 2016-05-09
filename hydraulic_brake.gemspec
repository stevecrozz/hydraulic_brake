Gem::Specification.new do |s|
  s.name        = 'hydraulic_brake'
  s.version     = '0.1.1'
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = 'Ruby notifier for https://airbrake.io'
  s.description = <<DESC
This is a repacked version of the official airbrake-ruby gem. The only change
is HydraulicBrake = Airbrake.

The only reason for this is so that clients that formerly used hydraulic_brake
can update to airbrake-ruby with a bundle update. That makes it easier for
certain clients that have transitive dependencies on hydraulic_brake to
upgrade to airbrake-ruby even if they don't have full control over the whole
dependency chain.

If you can, you should directly depend on airbrake-ruby
DESC
  s.author      = 'Stephen Crosby'
  s.email       = 'stevecrozz@gmail.com'
  s.homepage    = 'https://github.com/stevecrozz/hydraulic_brake'
  s.license     = 'MIT'

  s.require_path = 'lib'
  s.files        = ['lib/airbrake-ruby.rb', *Dir.glob('lib/**/*')]
  s.test_files   = Dir.glob('spec/**/*')

  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rake', '~> 10'
  s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'webmock', '~> 1'
  s.add_development_dependency 'benchmark-ips', '~> 2'
end
