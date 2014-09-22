require 'auth_redis_user_connector'

module AuthClient
  class User
    def self.find_by(id: nil)
      return nil unless id

      new RedisUserConnector.get(id).merge('id' => id)
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
