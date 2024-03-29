# -*- encoding: utf-8 -*-
require File.expand_path('../lib/growlfire/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Scott Holden"]
  gem.email         = ["scott@sshconnection.com"]
  gem.description   = %q{Growlfire provides growl notifications via Campfire's steaming API}
  gem.summary       = %q{Growlfire provides growl notifications via Campfire's steaming API}
  gem.homepage      = "http://github.com/sholden/growlfire"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "growlfire"
  gem.require_paths = ["lib"]
  gem.version       = Growlfire::VERSION

  gem.add_dependency 'yajl-ruby', '~>1.1'
  gem.add_dependency 'ruby-growl', '~>4.0'
  gem.add_dependency 'em-http-request', '~>1.0'
end
