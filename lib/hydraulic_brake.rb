require 'airbrake-ruby'

module Airbrake
  def self.configure(notifier = :default)
    yield config = Airbrake::Config.new

    if configured?(notifier)
      @notifiers[notifier]
    else
      @notifiers[notifier] = Notifier.new(config)
    end
  end

  class Config
    def secure=(*)
    end

    def port=(*)
    end

    def api_key=(key)
      @project_id = key
      @project_key = key
    end

    def project_root=(val)
      @root_directory = val
    end
  end
end

HydraulicBrake = Airbrake
