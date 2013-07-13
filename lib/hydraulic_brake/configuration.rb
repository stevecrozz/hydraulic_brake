module HydraulicBrake
  # Used to set up and modify settings for the notifier.
  class Configuration

    OPTIONS = [
      :api_key,
      :backtrace_filters,
      :development_environments,
      :development_lookup,
      :environment_name,
      :framework,
      :host,
      :http_open_timeout,
      :http_read_timeout,
      :notifier_name,
      :notifier_url,
      :notifier_version,
      :params_filters,
      :port,
      :project_root,
      :protocol,
      :proxy_host,
      :proxy_pass,
      :proxy_port,
      :proxy_user,
      :rake_environment_filters,
      :rescue_rake_exceptions,
      :secure,
      :use_system_ssl_cert_chain,
    ].freeze

    # The API key for your project, found on the project edit form.
    attr_accessor :api_key

    # The host to connect to
    attr_accessor :host

    # The port on which your Airbrake server runs (defaults to 443 for secure
    # connections, 80 for insecure connections).
    attr_accessor :port

    # +true+ for https connections, +false+ for http connections.
    attr_accessor :secure

    # +true+ to use whatever CAs OpenSSL has installed on your system. +false+
    # to use the ca-bundle.crt file included in HydraulicBrake itself
    # (reccomended and default)
    attr_accessor :use_system_ssl_cert_chain

    # The HTTP open timeout in seconds (defaults to 2).
    attr_accessor :http_open_timeout

    # The HTTP read timeout in seconds (defaults to 5).
    attr_accessor :http_read_timeout

    # The hostname of your proxy server (if using a proxy)
    attr_accessor :proxy_host

    # The port of your proxy server (if using a proxy)
    attr_accessor :proxy_port

    # The username to use when logging into your proxy server (if using a proxy)
    attr_accessor :proxy_user

    # The password to use when logging into your proxy server (if using a proxy)
    attr_accessor :proxy_pass

    # A list of parameters that should be filtered out of what is sent to Airbrake.
    # By default, all "password" attributes will have their contents replaced.
    attr_reader :params_filters

    # A list of filters for cleaning and pruning the backtrace. See #filter_backtrace.
    attr_reader :backtrace_filters

    # A list of environment keys that will be ignored from what is sent to Airbrake server
    # Empty by default and used only in rake handler
    attr_reader :rake_environment_filters

    # A list of environments in which notifications should not be sent.
    attr_accessor :development_environments

    # +true+ if you want to check for production errors matching development errors, +false+ otherwise.
    attr_accessor :development_lookup

    # The name of the environment the application is running in
    attr_accessor :environment_name

    # The path to the project in which the error occurred, such as the Rails.root
    attr_accessor :project_root

    # The name of the notifier library being used to send notifications (such
    # as "HydraulicBrake Notifier")
    attr_accessor :notifier_name

    # The version of the notifier library being used to send notifications (such as "1.0.2")
    attr_accessor :notifier_version

    # The url of the notifier library being used to send notifications
    attr_accessor :notifier_url

    # The logger used by HydraulicBrake
    attr_accessor :logger

    # The framework HydraulicBrake is configured to use
    attr_accessor :framework

    # Should HydraulicBrake catch exceptions from Rake tasks?
    # (boolean or nil; set to nil to catch exceptions when rake isn't running from a terminal; default is nil)
    attr_accessor :rescue_rake_exceptions

    # User attributes that are being captured
    attr_accessor :user_attributes


    DEFAULT_PARAMS_FILTERS = %w(password password_confirmation).freeze

    DEFAULT_USER_ATTRIBUTES = %w(id name username email).freeze

    DEFAULT_BACKTRACE_FILTERS = [
      lambda { |line|
        if defined?(HydraulicBrake.configuration.project_root) && HydraulicBrake.configuration.project_root.to_s != ''
          line.sub(/#{HydraulicBrake.configuration.project_root}/, "[PROJECT_ROOT]")
        else
          line
        end
      },
      lambda { |line| line.gsub(/^\.\//, "") },
      lambda { |line|
        if defined?(Gem)
          Gem.path.inject(line) do |line, path|
            line.gsub(/#{path}/, "[GEM_ROOT]")
          end
        end
      },
      lambda { |line| line if line !~ %r{lib/hydraulic_brake} }
    ].freeze

    alias_method :secure?, :secure
    alias_method :use_system_ssl_cert_chain?, :use_system_ssl_cert_chain

    def initialize
      @secure                   = false
      @use_system_ssl_cert_chain= false
      @host                     = 'api.airbrake.io'
      @http_open_timeout        = 2
      @http_read_timeout        = 5
      @params_filters           = DEFAULT_PARAMS_FILTERS.dup
      @backtrace_filters        = DEFAULT_BACKTRACE_FILTERS.dup
      @development_environments = %w(development test cucumber)
      @development_lookup       = true
      @notifier_name            = 'HydraulicBrake Notifier'
      @notifier_version         = VERSION
      @notifier_url             = 'https://github.com/stevecrozz/hydraulic_brake'
      @framework                = 'Standalone'
      @rescue_rake_exceptions   = nil
      @user_attributes          = DEFAULT_USER_ATTRIBUTES.dup
      @rake_environment_filters = []
    end

    # Takes a block and adds it to the list of backtrace filters. When the filters
    # run, the block will be handed each line of the backtrace and can modify
    # it as necessary.
    #
    # @example
    #   config.filter_bracktrace do |line|
    #     line.gsub(/^#{Rails.root}/, "[Rails.root]")
    #   end
    #
    # @param [Proc] block The new backtrace filter.
    # @yieldparam [String] line A line in the backtrace.
    def filter_backtrace(&block)
      self.backtrace_filters << block
    end

    # Allows config options to be read like a hash
    #
    # @param [Symbol] option Key for a given attribute
    def [](option)
      send(option)
    end

    # Returns a hash of all configurable options
    def to_hash
      OPTIONS.inject({}) do |hash, option|
        hash[option.to_sym] = self.send(option)
        hash
      end
    end

    # Returns a hash of all configurable options merged with +hash+
    #
    # @param [Hash] hash A set of configuration options that will take precedence over the defaults
    def merge(hash)
      to_hash.merge(hash)
    end

    # Determines if the notifier will send notices.
    # @return [Boolean] Returns +false+ if in a development environment, +true+ otherwise.
    def public?
      !development_environments.include?(environment_name)
    end

    def port
      @port || default_port
    end

    # Determines whether protocol should be "http" or "https".
    # @return [String] Returns +"http"+ if you've set secure to +false+ in
    # configuration, and +"https"+ otherwise.
    def protocol
      if secure?
        'https'
      else
        'http'
      end
    end

    # Should HydraulicBrake send notifications asynchronously
    # (boolean, nil or callable; default is nil).
    # Can be used as callable-setter when block provided.
    def async(&block)
      if block_given?
        @async = block
      end
      @async
    end
    alias_method :async?, :async

    def async=(use_default_or_this)
      @async = use_default_or_this == true ?
        default_async_processor :
        use_default_or_this
    end

    def ca_bundle_path
      if use_system_ssl_cert_chain? && File.exist?(OpenSSL::X509::DEFAULT_CERT_FILE)
        OpenSSL::X509::DEFAULT_CERT_FILE
      else
        local_cert_path # ca-bundle.crt built from source, see resources/README.md
      end
    end

    def local_cert_path
      File.expand_path(File.join("..", "..", "..", "resources", "ca-bundle.crt"), __FILE__)
    end

  private
    # Determines what port should we use for sending notices.
    # @return [Fixnum] Returns 443 if you've set secure to true in your
    # configuration, and 80 otherwise.
    def default_port
      if secure?
        443
      else
        80
      end
    end

    # Async notice delivery defaults to girl friday
    def default_async_processor
      queue = GirlFriday::WorkQueue.new(nil, :size => 3) do |notice|
        HydraulicBrake.sender.send_to_airbrake(notice)
      end
      lambda {|notice| queue << notice}
    end
  end
end
