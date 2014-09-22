require 'active_support/concern'

module AuthClient
  module Permission
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_auth_client_permission(roles: roles)
        define_singleton_method :available_roles do
          roles
        end
      end
    end
  end
end
