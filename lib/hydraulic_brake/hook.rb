require 'net/http'
require 'uri'

module HydraulicBrake
  module Hook

    # Alerts Airbrake of a deploy.
    #
    # @param [Hash] opts Data about the deploy that is set to Airbrake
    #
    # @option opts [String] :api_key Api key of you Airbrake application
    # @option opts [String] :scm_revision The given revision/sha that is being deployed
    # @option opts [String] :scm_repository Address of your repository to help with code lookups
    # @option opts [String] :local_username Who is deploying
    def self.deploy(opts = {})
      api_key = opts.delete(:api_key) || HydraulicBrake.configuration.api_key
      if api_key.empty?
        puts "I don't seem to be configured with an API key.  Please check your configuration."
        return false
      end

      params = {'api_key' => api_key}
      opts.each {|k,v| params["deploy[#{k}]"] = v }

      host = HydraulicBrake.configuration.host
      port = HydraulicBrake.configuration.port

      proxy = Net::HTTP.Proxy(HydraulicBrake.configuration.proxy_host,
                              HydraulicBrake.configuration.proxy_port,
                              HydraulicBrake.configuration.proxy_user,
                              HydraulicBrake.configuration.proxy_pass)
      http = proxy.new(host, port)

      # Handle Security
      if HydraulicBrake.configuration.secure?
        http.use_ssl      = true
        http.ca_file      = HydraulicBrake.configuration.ca_bundle_path
        http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
      end

      post = Net::HTTP::Post.new("/deploys.txt")
      post.set_form_data(params)

      response = http.request(post)

      puts response.body
      return Net::HTTPSuccess === response
    end

  end
end


