require 'auth_redis_user_connector'

module AuthClient
  class User
    def self.find_by(id: nil)
      return nil unless id

      redis_data = RedisUserConnector.get(id)

      return nil if redis_data.empty?

      new redis_data.merge(:id => id)
    end

    def initialize(options)
      options.each_pair do |key, val|
        self.class_eval("def #{key}; @#{key}; end")
        self.instance_variable_set "@#{key}", val
      end
    end

    def to_s
      [surname, name, patronymic].compact.join(' ')
    end

    def permissions
      ::Permission.where :user_id => id
    end

    def has_permission?(role:, context: nil)
      context ?
        permissions.for_role(role).for_context(context).exists? :
        permissions.for_role(role).exists?
    end
  end
end
