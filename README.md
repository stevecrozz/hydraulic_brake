HydraulicBrake
========

This is a replacement notifier gem for the [Airbrake
gem](https://github.com/airbrake/airbrake) which is used
for integrating ruby apps with [Airbrake](http://airbrake.io).

### Transitioning from Airbrake to HydraulicBrake

HydraulicBrake is a lighter weight alternative to the [Airbrake
gem](https://github.com/airbrake/airbrake) and takes a different design
approach. HydraulicBrake doesn't attempt to integrate with any
frameworks and has few dependencies. HydraulicBrake doesn't change
anything outside its own namespace. It doesn't do any automatic
exception handling or configuration.

Configuration
-------------

Configure HydraulicBrake when your app starts with a configuration block
like this one:

    HydraulicBrake.configure do |config|
      config.host = "api.airbrake.io"
      config.port = "443"
      config.secure = true
      config.environment_name = "staging"
      config.api_key = "<api-key-from-your-airbrake-server>"
    end

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
      HydraulicBrake.notify(
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
