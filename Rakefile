# -*- ruby -*-
require 'rubygems'
require 'jeweler'
require './lib/obuf'

Jeweler::Tasks.new do |gem|
  gem.version = Obuf::VERSION
  gem.name = "obuf"
  gem.summary = "Ruby disk-backed object buffer"
  gem.description = "Stores marshaled temporary objects on-disk in a simple Enumerable"
  gem.email = "me@julik.nl"
  gem.homepage = "http://github.com/julik/obuf"
  gem.authors = ["Julik Tarkhanov"]
  gem.license = 'MIT'
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
desc "Run all tests"
Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

task :default => [ :test ]