require 'active_support/concern'
require 'auth_redis_user_connector'

module AuthClient
  module User
    extend ActiveSupport::Concern

    included do
      acts_as_auth_client_user
    end

    def to_s
      [surname, name, patronymic].compact.join(' ')
    end

    def fullname
      to_s
    end

    def app_name
    end

    def check_app_name
      raise 'User#app_name should not be blank' if app_name.blank?
    end

    def activity_notify
      check_app_name

      RedisUserConnector.set id, "#{app_name}_last_activity", Time.zone.now.to_i
    end

    def info_notify
      check_app_name

      RedisUserConnector.set id, "#{app_name}_info", info_hash.to_json
    end

    def info_hash
      { :permissions => permissions_info, :url => "https://#{app_name}.tusur.ru/" }
    end

    def permissions_info
      permissions.map { |p| { :role => p.role, :info => p.context.try(:to_s) }}
    end

    def after_signed_in
      info_notify
    end

    def last_activity_at
      return nil if app_name.blank?

      seconds = instance_variable_get("@#{app_name}_last_activity").to_i

      Time.at(seconds)
    end

    module ClassMethods
      def acts_as_auth_client_user
        define_method :permissions do
          ::Permission.where :user_id => id
        end

        define_method(:has_permission?) do |role:, context: nil|
          context ?
            permissions.for_role(role).for_context(context).exists? :
            permissions.for_role(role).exists?
        end
      end

      def find_by(id:)
        redis_data = RedisUserConnector.get(id)

        return nil if (redis_data.nil? || redis_data.empty?)

        attributes = redis_data.merge(:id => id)

        build_user attributes
      end

      private

      def build_user(attributes)
        new.tap do |user|
          attributes.each do |attribute, value|
            name = "@#{attribute}"
            user.instance_variable_set name, value

            user.define_singleton_method attribute do
              instance_variable_get name
            end
          end
        end
      end
    end
  end
end
