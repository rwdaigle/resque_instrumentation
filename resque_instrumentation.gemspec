$:.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'lib/resque/plugins/instrumentation/version'

Gem::Specification.new do |s|

  s.name        = "resque_instrumentation"
  s.version     = "#{Resque::Plugins::Instrumentation::VERSION}"
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.homepage    = "https://github.com/rwdaigle/resque_instrumentation"
  s.authors     = ["Ryan Daigle"]
  s.email       = "ryan.daigle@gmail.com"

  s.summary     = "Resque instrumentation plugin"
  s.description = "Resque plugin to instrument at each of Resque's pre-defined hooks."

  s.license     = 'MIT'
  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency "resque", "~> 1.24"
  s.add_development_dependency "minitest"
end
