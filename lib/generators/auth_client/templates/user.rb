class User
  include AuthClient::User

  def app_name
    Settings['app.host']
  end
end
