require File.expand_path("../lib/mongoid_flaggable/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "mongoid_flaggable"
  s.version     = Mongoid::Flaggable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steve McHail"]
  s.email       = ["mchail@gmail.com"]
  s.homepage    = "http://github.com/mchail/mongoid_flaggable"
  s.summary     = "Add and manipulate flags (boolean values) on mongoid models"
  s.description     = "Add and manipulate flags (boolean values) on mongoid models"

  s.required_rubygems_version = ">= 1.3.6"

  # lol - required for validation
  s.rubyforge_project         = "mongoid_flaggable"

  # If you have other dependencies, add them here
  s.add_dependency "mongoid"#, "~> 1.2"

  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'

  # If you need an executable, add it here
  # s.executables = ["newgem"]

  # If you have C extensions, uncomment this line
  # s.extensions = "ext/extconf.rb"
end