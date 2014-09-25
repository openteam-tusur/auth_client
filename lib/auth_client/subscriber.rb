require 'auth_redis_user_connector'
require 'daemons'

module AuthClient
  class Subscriber < ::Rails::Railtie
    rake_tasks do
      namespace :subscriber do
        desc 'Start listen channel'
        task :start => :environment do
          Daemons.call(:app_name => 'subscriber', :multiple => false,   :dir_mode   => :normal, :dir => "tmp/pids", :log_dir => "log") do
            RedisUserConnector.sub('broadcast') do |on|
              on.subscribe do
                Rails.logger.info 'Subscribed to broadcast'
              end

              on.message do |_, message|
                Rails.logger.info "Recieved message about user <#{message}> signed in"
                user = ::User.find_by(:id => message )
                user.after_signied_in if user
              end
            end
          end
        end

        desc 'Stop listen channel'
        task :stop => :environment do
          Daemons::Monitor.find('tmp/pids', 'subscriber').try :stop
        end

        desc 'Restart subscriber'
        task :restart => :environment do
          Rake::Task['subscriber:stop'].invoke
          Rake::Task['subscriber:start'].invoke
        end
      end
    end
  end
end
