require 'rubygems'
require 'rake'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rrdsimple'

GEM = 'rrdsimple'
GEM_NAME = 'rrdsimple'
GEM_VERSION = RRDSimple::VERSION
AUTHORS = ['Edgar Gonzalez']
EMAIL = "edgargonzalez@gmail.com"
HOMEPAGE = "http://github.com/edgar/RRDSimple"
SUMMARY = "A simple round robin database pattern via Redis"

begin
  require "jeweler"
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = GEM
    gemspec.version = GEM_VERSION
    gemspec.summary = SUMMARY
    gemspec.platform = Gem::Platform::RUBY
    gemspec.description = gemspec.summary
    gemspec.email = EMAIL
    gemspec.homepage = HOMEPAGE
    gemspec.authors = AUTHORS
    gemspec.required_ruby_version = ">= 1.8"
    gemspec.add_dependency("redis", ">= 2.0.3")
    gemspec.add_development_dependency "rspec", ">= 1.3.0"
    gemspec.rubyforge_project = GEM
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

