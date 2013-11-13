# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'sigdump'

Gem::Specification.new do |gem|
  gem.name        = "sigdump"
  gem.description = "Setup signal handler which dumps backtrace of running threads and number of allocated objects per class. Require 'sigdump/setup', send SIGCONT, and see /tmp/sigdump-<pid>.log."
  gem.homepage    = "https://github.com/frsyuki/sigdump"
  gem.summary     = gem.description
  gem.version     = Sigdump::VERSION
  gem.authors     = ["Sadayuki Furuhashi"]
  gem.email       = ["frsyuki@gmail.com"]
  gem.license     = "MIT"
  gem.has_rdoc    = false
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_development_dependency "rake", ">= 0.9.2"
end
