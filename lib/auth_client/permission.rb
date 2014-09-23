require 'active_support/concern'

module AuthClient
  module Permission
    extend ActiveSupport::Concern

    def user
      User.find_by id: user_id
    end

    module ClassMethods
      def acts_as_auth_client_permission(roles: roles)
        define_singleton_method :available_roles do
          roles.map(&:to_s)
        end

        belongs_to :context, :polymorphic => true

        scope :for_role, ->(role) { where(:role => role)  }
        scope :for_context, ->(context) { where(:context_id => context.try(:id), :context_type => context.try(:class))  }

        validates_inclusion_of :role, :in => available_roles + available_roles.map(&:to_sym)
        validates_presence_of :role

        permissionize_user
      end

      private

      def permissionize_user
        AuthClient::User.class_eval do
          def permissions
            ::Permission.where :user_id => id
          end

          ::Permission.available_roles.each do |role|
            define_method "#{role}_of?" do |context|
              permissions.for_role(role).for_context(context).exists?
            end

            define_method "#{role}?" do
              permissions.for_role(role).exists?
            end
          end
        end
      end
    end
  end
end
