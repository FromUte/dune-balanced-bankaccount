# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dune/balanced/bankaccount/version'

Gem::Specification.new do |spec|
  spec.name          = 'dune-balanced-bankaccount'
  spec.version       = Dune::Balanced::Bankaccount::VERSION
  spec.authors       = ['Legrand Pierre']
  spec.email         = %w(legrand.work@gmail.com)
  spec.summary       = 'dune-investissement integration with Bank Account Balanced Payments from neighborly.'
  spec.description   = 'Integration with Balanced Payments on dune-investissement specifically with Bank Accounts.'
  spec.homepage      = 'https://github.com/FromUte/dune-balanced-bankaccount'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'dune-balanced', '~> 1.0'

  spec.add_dependency 'rails',   '~> 4.0'
  spec.add_dependency 'slim',    '~> 2.0'
  spec.add_dependency 'sidekiq', '~> 3.0'
  spec.add_development_dependency 'rspec-rails',      '~> 2.14'
  spec.add_development_dependency 'shoulda-matchers', '~> 2.5'
  spec.add_development_dependency 'webmock'
end
