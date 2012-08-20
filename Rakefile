require 'rake'

GEMSPEC = eval(File.read(Dir["*.gemspec"][0]))

task :default => [:build]

task :build do
  sh "gem build #{GEMSPEC.name}.gemspec"
end

task :install => :build do
  sh "gem install #{GEMSPEC.name}-#{GEMSPEC.version}.gem"
end

task :test do
  require './lib/mayuki.rb'
  Mayuki::mayuki("tests/")
end
