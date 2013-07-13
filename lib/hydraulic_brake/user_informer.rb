module HydraulicBrake
  class UserInformer
    def initialize(app)
      @app = app
    end

    def replacement(with)
      HydraulicBrake.configuration.user_information.gsub(/\{\{\s*error_id\s*\}\}/, with.to_s)
    end

    def call(env)
      status, headers, body = @app.call(env)
      if env['hydraulic_brake.error_id'] && HydraulicBrake.configuration.user_information
        new_body = []
        replace  = replacement(env['hydraulic_brake.error_id'])
        body.each do |chunk|
          new_body << chunk.gsub("<!-- HYDRAULICBRAKE ERROR -->", replace)
        end
        body.close if body.respond_to?(:close)
        headers['Content-Length'] = new_body.sum(&:bytesize).to_s
        body = new_body
      end
      [status, headers, body]
    end
  end
end

