class User
  include AuthClient::User

  def app_name
    Settings['app.host'].to_s.parameterize('_')
  end
end
