# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'auth_client/version'

Gem::Specification.new do |spec|
  spec.name          = "auth_client"
  spec.version       = AuthClient::VERSION
  spec.authors       = ["OpenTeam"]
  spec.email         = ["developers@openteam.ru"]
  spec.summary       = %q{Auth Client}
  spec.description   = %q{Auth Client}
  spec.homepage      = "https://github.com/openteam-com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
