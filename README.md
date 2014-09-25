# AuthClient

## Installation

Add this line to your application's Gemfile:

    gem 'auth_client'

And then execute:

    $ bundle
    
Run generator:

    bundle exec rails generate auth_client:install
    
Or use similar models

```ruby
class User
  include AuthClient::User
  
  # your code goes here
end
```

```ruby
class Permission < ActiveRecord::Base
  include AuthClient::Permission

  acts_as_auth_client_permission roles: [:admin]
  
  # your code goes here
end
```
