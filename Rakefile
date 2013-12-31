require "bundler"
require "bundler/gem_tasks"
Bundler.setup

# require "rspec/core/rake_task"
# Rspec::Core::RakeTask.new(:spec)

task :default => :build

gemspec = eval(File.read("mongoid_flaggable.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["mongoid_flaggable.gemspec"] do
  system "gem build mongoid_flaggable.gemspec"
  system "gem install mongoid_flaggable-#{Mongoid::Flaggable::VERSION}.gem"
end