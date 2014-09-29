# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'spree_smarty_streets_address_verification'
  s.version = '2.3.2'
  s.summary = 'Address verification via smarty streets for Spree'
  s.description=<<DESCRIPTION
    Decorates the Address object so the address is verified and normalized
    any time any of the address fields are updated. Uses Smarty Strees for the
    address verification service.
DESCRIPTION
  s.required_ruby_version = '>= 1.9.3'

  s.author = 'Eric Anderson'
  s.email = 'eric@railsdog.com'
  s.homepage = 'http://www.railsdog.com'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.3.2'
  s.add_dependency 'smartystreets'

  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'factory_girl', '~> 4.4'
  s.add_development_dependency 'rspec-rails', '~> 2.13'
  s.add_development_dependency 'sass-rails', '~> 4.0.2'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'dotenv'
  s.add_development_dependency 'webmock'
end
