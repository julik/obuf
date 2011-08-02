# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.spec 'obuf' do | p |
  p.developer('Julik Tarkhanov', 'me@julik.nl')

  p.readme_file   = 'README.rdoc'
  p.extra_rdoc_files  = FileList['*.rdoc'] + FileList['*.txt']
  p.extra_dev_deps = {"flexmock" => "~> 0.8", "cli_test" => "~>1.0"}
  p.clean_globs = File.read(File.dirname(__FILE__) + "/.gitignore").split(/\s/).to_a
end

# vim: syntax=ruby
