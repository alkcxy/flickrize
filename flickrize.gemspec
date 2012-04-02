$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "flickrize/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "flickrize"
  s.version     = Flickrize::VERSION
  s.authors     = ["Alessio Caradossi"]
  s.email       = ["alessio@theeyes.org"]
  s.homepage    = "http://vivilazio.it"
  s.summary     = "Create a model to use flickraw with easyness"
  s.description = "Create a model to use flickraw with easyness and will paginate for paginating any photoset. I use this code on my projects, it is very _ugly_ and *without test code* nor *documentation* (not yet)! Use at your own risk!!!"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  #s.add_development_dependency "sqlite3"
  
  s.add_dependency "flickraw", "~> 0.9.5"
  s.add_dependency "will_paginate", "~> 3.0"
  s.add_dependency "rails", "~> 3.1.3"
end
