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

        return nil if redis_data.empty?

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
