module HydraulicBrake
  module TestNotification

    def self.send
      begin
        raise "Testing hydraulic brake notifier. If you can see this, it works."
      rescue Exception => e
        puts "Configuration:"
        HydraulicBrake.configuration.to_hash.each do |key, value|
          puts sprintf("%25s: %s", key.to_s, value.inspect.slice(0, 55))
        end
        print "Sending notification... "
        HydraulicBrake.notify(e)
        print "done\n"
      end
    end

  end
end
