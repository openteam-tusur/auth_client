require 'active_support/concern'
require 'configliere'

module AuthClient
  module Helpers
    extend ActiveSupport::Concern

    included do
      before_action :check_session
    end

    def current_user
      @current_user ||= ::User.find_by(id: session_user_id)
    end

    def user_signed_in?
      !!current_user
    end

    def sign_in_url
      uri = URI.parse(Settings['auth_server.sign_in_url'])

      uri.query = { :redirect_url => request.original_url }.to_query

      uri.to_s
    end

    def sign_out_url
      uri = URI.parse(Settings['auth_server.sign_out_url'])

      uri.query = { :redirect_url => request.original_url }.to_query

      uri.to_s
    end

    private

    def session_user_id
      session['warden.user.user.key'].try(:first).try(:first)
    end

    def check_session
      if session['warden.user.user.session']
        last_request_at = session['warden.user.user.session']['last_request_at']
        if Time.zone.now.to_i - last_request_at > 1800
          session.clear
        else
          session['warden.user.user.session']['last_request_at'] = Time.zone.now.to_i

          current_user.activity_notify if current_user
        end
      end
    end
  end
end

ActiveSupport.on_load :action_controller do
  include AuthClient::Helpers

  helper_method :current_user, :user_signed_in?, :sign_in_url, :sign_out_url
end
