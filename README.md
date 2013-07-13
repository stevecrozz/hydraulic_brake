HydraulicBrake
========

This is a replacement notifier gem for integrating apps with [Airbrake](http://airbrake.io).

The [Airbrake gem](https://github.com/airbrake/airbrake) is too
heavyweight and brings in unnecessary dependencies like activesupport.
It also automatically installs Rack middlware and automatically includes
itself into ActiveRecord::Base. HydraulicBrake doesn't do anything
automatically and has only a few dependencies.

When an uncaught exception occurs, HydraulicBrake will POST the relevant
data to the Airbrake server specified in your environment.

### Transitioning from Airbrake to HydraulicBrake

Usage
-----

Wherever you want to notify an Airbrake server, just call
HydraulicBrake#notify

    begin
      params = {
        # params that you pass to a method that can throw an exception
      }
      my_unpredicable_method(params)
    rescue => e
      HydraulicBrake.notify_or_ignore(
        :error_class   => "Special Error",
        :error_message => "Special Error: #{e.message}",
        :parameters    => params
      )
    end

HydraulicBrake merges the hash you pass with these default options:

    {
      :api_key       => HydraulicBrake.api_key,
      :error_message => 'Notification',
      :backtrace     => caller,
      :parameters    => {},
      :session       => {}
    }

You can override any of those parameters.

### Sending shell environment variables when "Going beyond exceptions"

One common request we see is to send shell environment variables along with
manual exception notification.  We recommend sending them along with CGI data
or Rack environment (:cgi_data or :rack_env keys, respectively.)

See HydraulicBrake::Notice#initialize in lib/hydraulic_brake/notice.rb for
more details.

Tracking deployments in HydraulicBrake
--------------------------------

When HydraulicBrake is installed as a gem, you need to add

    require 'hydraulic_brake/capistrano'

to your deploy.rb

If you don't use Capistrano, then you can use the following rake task from your
deployment process to notify Airbrake:

    rake hydraulicbrake:deploy TO=#{env} REVISION=#{current_revision} REPO=#{repository} USER=#{local_user}

Testing
-------

When you run your tests, you might notice that the Airbrake service is
recording notices generated using #notify when you don't expect it to.
You can use code like this in your test_helper.rb or spec_helper.rb
files to redefine that method so those errors are not reported while
running tests.

    module Airbrake
      def self.notify(exception, opts = {})
        # do nothing.
      end
    end

Proxy Support
-------------

The notifier supports using a proxy, if your server is not able to
directly reach the Airbrake servers. To configure the proxy settings,
added the following information to your HydraulicBrake configuration
block.

    HydraulicBrake.configure do |config|
      config.proxy_host = proxy.host.com
      config.proxy_port = 4038
      config.proxy_user = foo # optional
      config.proxy_pass = bar # optional
      
Logging
------------

HydraulicBrake uses STDOUT by default. If you don't like HydraulicBrake
scribbling to your standard output, just pass another `Logger` instance
inside your configuration:

    HydraulicBrake.configure do |config|
      ...
      config.logger = Logger.new("path/to/your/log/file")
    end

Development
-----------

See TESTING.md for instructions on how to run the tests.

Credits
-------

Thank you to all [the airbrake contributors](https://github.com/airbrake/airbrake/contributors)!

License
-------

Airbrake is Copyright © 2008-2012 Airbrake. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
