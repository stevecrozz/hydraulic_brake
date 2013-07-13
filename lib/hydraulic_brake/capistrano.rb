# Defines deploy:notify_airbrake which will send information about the deploy to Airbrake.
require 'capistrano'

module HydraulicBrake
  module Capistrano
    def self.load_into(configuration)
      configuration.load do
        after "deploy",            "hydraulic_brake:deploy"
        after "deploy:migrations", "hydraulic_brake:deploy"

        namespace :hydraulic_brake do
          desc <<-DESC
            Notify Airbrake of the deployment by running the notification on the REMOTE machine.
              - Run remotely so we use remote API keys, environment, etc.
          DESC
          task :deploy, :except => { :no_release => true } do
            env = fetch(:env, "production")
            local_user = ENV['USER'] || ENV['USERNAME']
            executable = RUBY_PLATFORM.downcase.include?('mswin') ? fetch(:rake, 'rake.bat') : fetch(:rake, 'rake')
            directory = configuration.current_release
            notify_command = "cd #{directory}; #{executable} hydraulic_brake:deploy TO=#{env} REVISION=#{current_revision} REPO=#{repository} USER=#{local_user}"
            notify_command << " DRY_RUN=true" if dry_run
            notify_command << " API_KEY=#{ENV['API_KEY']}" if ENV['API_KEY']
            logger.info "Notifying Airbrake of Deploy (#{notify_command})"
            if configuration.dry_run
              logger.info "DRY RUN: Notification not actually run."
            else
              result = ""
              run(notify_command, :once => true) { |ch, stream, data| result << data }
              # TODO: Check if SSL is active on account via result content.
            end
            logger.info "HydraulicBrake Notification Complete."
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  HydraulicBrake::Capistrano.load_into(Capistrano::Configuration.instance)
end
