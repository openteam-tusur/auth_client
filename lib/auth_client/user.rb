require 'auth_redis_user_connector'

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
end

