require "auth_client/version"

require 'auth_client/user'
require 'auth_client/auth_client_helpers'

module AuthClient
end

ActiveSupport.on_load :action_controller do
  include AuthClientHelpers

  helper_method :current_user, :user_signed_in?, :sign_in_url, :sign_out_url
end
