# HydraulicBrake [![Build Status](https://travis-ci.org/stevecrozz/hydraulic_brake.svg?branch=master)](https://travis-ci.org/stevecrozz/hydraulic_brake)

This is a replacement notifier gem for the [Airbrake
gem](https://github.com/airbrake/airbrake) which is used
for integrating ruby apps with [Airbrake](http://airbrake.io).

### Transitioning from Airbrake to HydraulicBrake

HydraulicBrake is a lighter weight alternative to the [Airbrake
gem](https://github.com/airbrake/airbrake) and takes a different design
approach. HydraulicBrake doesn't attempt to integrate with any
frameworks and has few dependencies. HydraulicBrake doesn't change
anything outside its own namespace. It doesn't do any automatic
exception handling or configuration. HydraulicBrake doesn't ignore any
exceptions. If you don't want to send a notification, then don't call
HydraulicBrake#notify.

If you were previously using the Airbrake gem, and you want to use
HydraulicBrake instead, you'll need to install error handlers wherever
you intend to catch errors. The right place to do that depends entirely
on your application, but a good place to start would be
rescue_action_in_public for rails apps and Rack middleware for Rack
apps.

Configuration
-------------

Configure HydraulicBrake when your app starts with a configuration block
like this one:

```ruby
HydraulicBrake.configure do |config|
  config.host = "api.airbrake.io"
  config.port = "443"
  config.secure = true
  config.environment_name = "staging"
  config.api_key = "<api-key-from-your-airbrake-server>"
end
```

Usage
-----

Wherever you want to notify an Airbrake server, just call
HydraulicBrake#notify

```ruby
begin
  my_unpredicable_method
rescue => e
  HydraulicBrake.notify(
    :error_class   => "Special Error",
    :error_message => "Special Error: #{e.message}",
    :parameters    => params
  )
end
```

HydraulicBrake merges the hash you pass with these default options:

```ruby
{
  :api_key       => HydraulicBrake.api_key,
  :error_message => 'Notification',
  :backtrace     => caller,
  :parameters    => {},
  :session       => {}
}
```

You can override any of those parameters and there are many other
parameters you can add. See the inline documentation for
HydraulicBrake#notify.

Async Notifications
-------------------

HydraulicBrake doesn't provide anything special for async notifications.
Just wrap your calls to Airbrake#notify in the async library of your
choice if you want to.

Proxy Support
-------------

The notifier supports using a proxy. To configure a proxy, add the
configuration to HydraulicBrake#configure:

```ruby
HydraulicBrake.configure do |config|
  config.proxy_host = proxy.host.com
  config.proxy_port = 4038
  config.proxy_user = foo # optional
  config.proxy_pass = bar # optional
end
```
      
Logging
------------

HydraulicBrake uses STDOUT by default. If you want to use a different
logger, just pass another `Logger` instance inside your configuration:

```ruby
HydraulicBrake.configure do |config|
  config.logger = Logger.new("path/to/your/log/file")
end
```

Deploy Hook
-----------

HydraulicBrake can notify Airbrake whenever you deploy your app. Just
call HydraulicBrake::Hook#deploy whenever you deploy:

```ruby
HydraulicBrake::Hook.deploy({
  :scm_revision => "cd6b969f66ad0794c7117d5030f926b49f82b038",
  :scm_repository => "stevecrozz/hydraulic_brake",
  :local_username => "stevecrozz",
  :rails_env => "production", # everything is rails, right?
  :message => "Another deployment hook brought to you by HydraulicBrake"
})
```

Credits
-------

Thank you to all [the airbrake
contributors](https://github.com/airbrake/airbrake/contributors) for
making HydraulicBrake possible.

License
-------

Airbrake is Copyright © 2008-2012 Airbrake.
HydraulicBrake is CopyRight © 2013 Stephen Crosby. It is free software,
and may be redistributed under the terms specified in the MIT-LICENSE
file.
