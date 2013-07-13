require 'builder'
require 'socket'

module HydraulicBrake
  class Notice

    class << self
      def attr_reader_with_tracking(*names)
        attr_readers.concat(names)
        attr_reader_without_tracking(*names)
      end

      alias_method :attr_reader_without_tracking, :attr_reader
      alias_method :attr_reader, :attr_reader_with_tracking


      def attr_readers
        @attr_readers ||= []
      end
    end

    # The exception that caused this notice, if any
    attr_reader :exception

    # The API key for the project to which this notice should be sent
    attr_reader :api_key

    # The backtrace from the given exception or hash.
    attr_reader :backtrace

    # The name of the class of error (such as RuntimeError)
    attr_reader :error_class

    # The name of the server environment (such as "production")
    attr_reader :environment_name

    # CGI variables such as HTTP_METHOD
    attr_reader :cgi_data

    # The message from the exception, or a general description of the error
    attr_reader :error_message

    # See Configuration#backtrace_filters
    attr_reader :backtrace_filters

    # See Configuration#params_filters
    attr_reader :params_filters

    # A hash of parameters from the query string or post body.
    attr_reader :parameters
    alias_method :params, :parameters

    # The component (if any) which was used in this request (usually the controller)
    attr_reader :component
    alias_method :controller, :component

    # The action (if any) that was called in this request
    attr_reader :action

    # A hash of session data from the request
    attr_reader :session_data

    # The path to the project that caused the error (usually Rails.root)
    attr_reader :project_root

    # The URL at which the error occurred (if any)
    attr_reader :url

    # The name of the notifier library sending this notice, such as "HydraulicBrake Notifier"
    attr_reader :notifier_name

    # The version number of the notifier library sending this notice, such as "2.1.3"
    attr_reader :notifier_version

    # A URL for more information about the notifier library sending this notice
    attr_reader :notifier_url

    # The host name where this error occurred (if any)
    attr_reader :hostname

    # Details about the user who experienced the error
    attr_reader :user

    private

    # Private writers for all the attributes
    attr_writer :exception, :api_key, :backtrace, :error_class, :error_message,
      :backtrace_filters, :parameters, :params_filters, :project_root, :url,
      :notifier_name, :notifier_url, :notifier_version, :component, :action,
      :cgi_data, :environment_name, :hostname, :user, :session_data

    # Arguments given in the initializer
    attr_accessor :args

    public

    def initialize(args)
      self.args         = args
      self.exception    = args[:exception]
      self.api_key      = args[:api_key]
      self.project_root = args[:project_root]
      self.url          = args[:url]

      self.notifier_name    = args[:notifier_name]
      self.notifier_version = args[:notifier_version]
      self.notifier_url     = args[:notifier_url]

      self.backtrace_filters   = args[:backtrace_filters]   || []
      self.params_filters      = args[:params_filters]      || []
      self.parameters          = args[:parameters] || {}
      self.component           = args[:component] || args[:controller] || nil
      self.action              = args[:action] || nil

      self.environment_name = args[:environment_name]
      self.cgi_data         = args[:cgi_data] || {}
      self.backtrace        = Backtrace.parse(exception_attribute(:backtrace, caller), :filters => self.backtrace_filters)
      self.error_class      = exception_attribute(:error_class) {|exception| exception.class.name }
      self.error_message    = exception_attribute(:error_message, 'Notification') do |exception|
        "#{exception.class.name}: #{args[:error_message] || exception.message}"
      end
      self.session_data = args[:session_data] || {}

      self.hostname        = local_hostname
      self.user = args[:user] || {}

      clean_params
    end

    # Converts the given notice to XML
    def to_xml
      builder = Builder::XmlMarkup.new
      builder.instruct!
      xml = builder.notice(:version => HydraulicBrake::API_VERSION) do |notice|
        notice.tag!("api-key", api_key)
        notice.notifier do |notifier|
          notifier.name(notifier_name)
          notifier.version(notifier_version)
          notifier.url(notifier_url)
        end
        notice.error do |error|
          error.tag!('class', error_class)
          error.message(error_message)
          error.backtrace do |backtrace|
            self.backtrace.lines.each do |line|
              backtrace.line(:number => line.number,
                             :file   => line.file,
                             :method => line.method)
            end
          end
        end

        if request_present?
          notice.request do |request|
            request.url(url)
            request.component(controller)
            request.action(action)
            unless parameters.nil? || parameters.empty?
              request.params do |params|
                xml_vars_for(params, parameters)
              end
            end
            unless session_data.empty?
              request.session do |session|
                xml_vars_for(session, session_data)
              end
            end
            unless cgi_data.nil? || cgi_data.empty?
              request.tag!("cgi-data") do |cgi_datum|
                xml_vars_for(cgi_datum, cgi_data)
              end
            end
          end
        end

        notice.tag!("server-environment") do |env|
          env.tag!("project-root", project_root)
          env.tag!("environment-name", environment_name)
          env.tag!("hostname", hostname)
        end
        unless user.empty?
          notice.tag!("current-user") do |u|
            u.tag!("id",user[:id])
            u.tag!("name",user[:name])
            u.tag!("email",user[:email])
            u.tag!("username",user[:username])
          end
        end
      end
      xml.to_s
    end

    # Allows properties to be accessed using a hash-like syntax
    #
    # @example
    #   notice[:error_message]
    # @param [String] method The given key for an attribute
    # @return The attribute value, or self if given +:request+
    def [](method)
      case method
      when :request
        self
      else
        send(method)
      end
    end

    private

    def request_present?
      url ||
        controller ||
        action ||
        !parameters.empty? ||
        !cgi_data.empty? ||
        !session_data.empty?
    end

    # Gets a property named +attribute+ of an exception, either from an actual
    # exception or a hash.
    #
    # If an exception is available, #from_exception will be used. Otherwise,
    # a key named +attribute+ will be used from the #args.
    #
    # If no exception or hash key is available, +default+ will be used.
    def exception_attribute(attribute, default = nil, &block)
      (exception && from_exception(attribute, &block)) || args[attribute] || default
    end

    # Gets a property named +attribute+ from an exception.
    #
    # If a block is given, it will be used when getting the property from an
    # exception. The block should accept and exception and return the value for
    # the property.
    #
    # If no block is given, a method with the same name as +attribute+ will be
    # invoked for the value.
    def from_exception(attribute)
      if block_given?
        yield(exception)
      else
        exception.send(attribute)
      end
    end

    # Removes non-serializable data from the given attribute.
    # See #clean_unserializable_data
    def clean_unserializable_data_from(attribute)
      self.send(:"#{attribute}=", clean_unserializable_data(send(attribute)))
    end

    # Removes non-serializable data. Allowed data types are strings, arrays,
    # and hashes. All other types are converted to strings.
    # TODO: move this onto Hash
    def clean_unserializable_data(data, stack = [])
      return "[possible infinite recursion halted]" if stack.any?{|item| item == data.object_id }

      if data.respond_to?(:to_hash)
        data.to_hash.inject({}) do |result, (key, value)|
          result.merge(key => clean_unserializable_data(value, stack + [data.object_id]))
        end
      elsif data.respond_to?(:to_ary)
        data.to_ary.collect do |value|
          clean_unserializable_data(value, stack + [data.object_id])
        end
      else
        data.to_s
      end
    end

    # Replaces the contents of params that match params_filters.
    # TODO: extract this to a different class
    def clean_params
      clean_unserializable_data_from(:parameters)
      filter(parameters)
      if cgi_data
        clean_unserializable_data_from(:cgi_data)
        filter(cgi_data)
      end
    end

    def filter(hash)
      if params_filters
        hash.each do |key, value|
          if filter_key?(key)
            hash[key] = "[FILTERED]"
          elsif value.respond_to?(:to_hash)
            filter(hash[key])
          end
        end
      end
    end

    def filter_key?(key)
      params_filters.any? do |filter|
        key.to_s.eql?(filter.to_s)
      end
    end

    def xml_vars_for(builder, hash)
      hash.each do |key, value|
        if value.respond_to?(:to_hash)
          builder.var(:key => key){|b| xml_vars_for(b, value.to_hash) }
        else
          builder.var(value.to_s, :key => key)
        end
      end
    end

    def local_hostname
      Socket.gethostname
    end

    def to_s
      content = []
      self.class.attr_readers.each do |attr|
        content << "  #{attr}: #{send(attr)}"
      end
      content.join("\n")
    end
  end
end
