require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => [:test]
       
desc 'Run all tests, test-spec, mocha, and pdf-reader required'
Rake::TestTask.new do |test|
  # test.ruby_opts  << '-w'  # .should == true triggers a lot of warnings
  test.libs       << 'spec'
  test.test_files =  Dir[ 'spec/*_spec.rb' ]
  test.verbose    =  true
end

desc 'genrates documentation'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( 'README',
                           'COPYING',
                           'LICENSE', 
                           'lib/' )
  rdoc.main     = 'README'
  rdoc.rdoc_dir = 'doc/html'
  rdoc.title    = 'Prawn::Text::Oval Documentation'
end 
