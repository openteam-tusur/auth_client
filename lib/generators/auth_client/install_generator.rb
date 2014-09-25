require 'rails/generators'

module AuthClient
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    desc 'Setup AuthClient'

    def copy_user
      copy_file 'user.rb', 'app/models/user.rb'
    end

    def copy_permission
      copy_file 'permission.rb', 'app/models/permission.rb'
    end
  end
end
