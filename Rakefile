require 'rubygems'
require 'rake'

begin
  require "jeweler"
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rcircular"
    gemspec.summary = "A kind of Round robin database pattern via Redis"
    gemspec.description = gemspec.summary
    gemspec.email = "edgargonzalez@gmail.com"
    gemspec.homepage = "http://github.com/edgar/RRDSimple"
    gemspec.authors = ["Edgar Gonzalez"]
    gemspec.required_ruby_version = ">= 1.8"
    gemspec.add_dependency("redis", ">= 2.0.3")
    gemspec.add_development_dependency "rspec", ">= 1.3.0"
    gemspec.rubyforge_project = "rrdsimple"
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "models #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

