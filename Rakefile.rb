$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
require 'heliotrope/version'
require 'find'
 
# Don't include resource forks in tarballs on Mac OS X.
ENV['COPY_EXTENDED_ATTRIBUTES_DISABLE'] = 'true'
ENV['COPYFILE_DISABLE'] = 'true'
 
# Gemspec
gemspec = Gem::Specification.new do |s|
  s.rubyforge_project = 'heliotrope-client'
 
  s.name = 'heliotrope-client'
  s.version = UState::VERSION
  s.author = 'Kyle Kingsbury'
  s.email = 'aphyr@aphyr.com'
  s.homepage = 'https://github.com/aphyr/heliotrope'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Client for the distributed processing system Fabric.'

  s.add_dependency 'beefcake', '>= 0.3.5' 
  s.add_dependency 'trollop', '>= 1.16.2'
   
  s.files = FileList['{lib}/**/*', 'LICENSE', 'README.markdown'].to_a
  s.executables = []
  s.require_path = 'lib'
  s.has_rdoc = true
 
  s.required_ruby_version = '>= 1.8.7'
end

Gem::PackageTask.new gemspec do |p|
end
 
RDoc::Task.new do |rd|
  rd.main = 'Heliotrope'
  rd.title = 'Heliotrope'
  rd.rdoc_dir = 'doc'
 
  rd.rdoc_files.include('lib/**/*.rb')
end
