require 'logger'
require 'net/http'
require 'net/https'
require 'rubygems'
require 'hydraulic_brake/async_sender'
require 'hydraulic_brake/backtrace'
require 'hydraulic_brake/configuration'
require 'hydraulic_brake/hook'
require 'hydraulic_brake/notice'
require 'hydraulic_brake/sender'
require 'hydraulic_brake/test_notification'
require 'hydraulic_brake/version'

module HydraulicBrake
  API_VERSION = "2.3"
  LOG_PREFIX = "** [HydraulicBrake] "

  HEADERS = {
    'Content-type'             => 'text/xml',
    'Accept'                   => 'text/xml, application/xml'
  }

  class << self
    # The sender object is responsible for delivering formatted data to the
    # Airbrake server.  Must respond to #send_to_airbrake. See
    # HydraulicBrake::Sender.
    attr_accessor :sender

    # A HydraulicBrake configuration object. Must act like a hash and return
    # sensible values for all HydraulicBrake configuration options. See
    # HydraulicBrake::Configuration.
    attr_writer :configuration

    # Tell the log that the Notifier is good to go
    def report_ready
      write_verbose_log("Notifier #{VERSION} ready to catch errors")
    end

    # Prints out the environment info to the log for debugging help
    def report_environment_info
      write_verbose_log("Environment Info: #{environment_info}")
    end

    # Prints out the response body from Airbrake for debugging help
    def report_response_body(response)
      write_verbose_log("Response from Airbrake: \n#{response}")
    end

    # Prints out the details about the notice that wasn't sent to server
    def report_notice(notice)
      write_verbose_log("Notice details: \n#{notice}")
    end

    # Returns the Ruby version, Rails version, and current Rails environment
    def environment_info
      info = "[Ruby: #{RUBY_VERSION}]"
      info << " [#{configuration.framework}]" if configuration.framework
      info << " [Env: #{configuration.environment_name}]" if configuration.environment_name
    end

    # Writes out the given message to the #logger
    def write_verbose_log(message)
      logger.debug LOG_PREFIX + message if logger
    end

    # Look for the Rails logger currently defined
    def logger
      self.configuration.logger
    end

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   HydraulicBrake.configure do |config|
    #     config.api_key = '1234567890abcdef'
    #     config.secure  = false
    #   end
    def configure(silent = false)
      yield(configuration)

      if configuration.async
        self.sender = AsyncSender.new(
          :sync_sender => Sender.new(configuration),
          :capacity => configuration.async_queue_capacity)
      else
        self.sender = Sender.new(configuration)
      end

      report_ready unless silent
      self.sender
    end

    # The configuration object.
    # @see HydraulicBrake.configure
    def configuration
      @configuration ||= Configuration.new
    end

    # Sends an exception manually using this method, even when you are not in a
    # controller.
    #
    # @param [Exception] exception The exception you want to notify Airbrake
    #   about
    # @param [Hash] opts Data that will be sent to Airbrake
    #
    # @option opts [String] :api_key The API key for this project. The API key
    #   is a unique identifier that Airbrake uses for identification
    # @option opts [String] :error_message The error returned by the exception
    #   (or the message you want to log)
    # @option opts [String] :backtrace A backtrace, usually obtained with
    #   +caller+
    # @option opts [String] :session_data The contents of the user's session
    # @option opts [String] :environment_name The application environment name
    def notify(exception, opts = {})
      send_notice build_notice_for(exception, opts)
    end

    def build_lookup_hash_for(exception, options = {})
      notice = build_notice_for(exception, options)

      result = {}
      result[:action]           = notice.action      rescue nil
      result[:component]        = notice.component   rescue nil
      result[:error_class]      = notice.error_class if notice.error_class
      result[:environment_name] = 'production'

      unless notice.backtrace.lines.empty?
        result[:file]        = notice.backtrace.lines.first.file
        result[:line_number] = notice.backtrace.lines.first.number
      end

      result
    end

    private

    def send_notice(notice)
      if configuration.public?
        sender.send_to_airbrake(notice)
      end
    end

    def build_notice_for(exception, opts = {})
      exception = unwrap_exception(exception)
      opts = opts.merge(:exception => exception) if exception.is_a?(Exception)
      opts = opts.merge(exception.to_hash) if exception.respond_to?(:to_hash)
      Notice.new(configuration.merge(opts))
    end

    def unwrap_exception(exception)
      if exception.respond_to?(:original_exception)
        exception.original_exception
      elsif exception.respond_to?(:continued_exception)
        exception.continued_exception
      else
        exception
      end
    end
  end
end
