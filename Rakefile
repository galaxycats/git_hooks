require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "git_hooks"
    gem.summary = %Q{A small Gem to provide various Git-Hooks based on Grit.}
    gem.description = %Q{The goal is to provide a pluggable hook infrastructure, where you can easily use different hooks for different purposes.}
    gem.email = "dirk.breuer@gmail.com"
    gem.homepage = "http://github.com/railsbros/git-hooks"
    gem.authors = ["Dirk Breuer"]
    gem.files = FileList["[A-Z]*.*", "lib/**/*"]

    gem.add_dependency "grit", ">= 2.0.0"
    gem.add_dependency "xmpp4r", ">= 0.5"
    gem.add_dependency "curb", ">= 0.7.1"
    gem.add_dependency "activesupport", ">= 3.0.0.beta"

    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "mocha", ">= 0.9.8"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
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
  rdoc.title = "git-hooks #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
