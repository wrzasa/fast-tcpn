# Used this istruction to create the gem:
# http://guides.rubygems.org/make-your-own-gem/
# some things below were based on docile gem.

$:.push File.expand_path('../lib', __FILE__)
require 'fast-tcpn/version'

Gem::Specification.new do |s|
  s.name = 'fast-tcpn'
  s.version = FastTCPN::VERSION
  s.authors = ['Wojciech Rząsa']
  s.email = %w(me@wojciechrzasa.pl)
  s.homepage = 'https://github.com/wrzasa/fast-tcpn'
  s.summary = 'FastTCPN is Ruby based modeling and simulation tool for simulation of TCPN with convenient DSL.'
  s.description = 'You can model your Timed Colored Petri Net in Ruby using convenient DSL and simulate it quite efficiently.'
  s.license = 'GPL-3.0'

  s.platform = 'ruby'
  s.required_ruby_version = '~> 2.0'

#  s.rubyforge_project = ''

  s.files = `git ls-files -z`.split("\x0")
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_runtime_dependency 'docile', '~> 1.1'

  # Running rspec tests from rake
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'simplecov', '~> 0'

  s.extra_rdoc_files << 'README.md'
  s.rdoc_options << '--main' << 'README.md'
  s.rdoc_options << '--title' << 'fast-tcpn -- Fast TCPN modeling and simulation tool'
  s.rdoc_options << '--line-numbers'
  s.rdoc_options << '-A'
  s.rdoc_options << '-x coverage'
end
