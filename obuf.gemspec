# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "obuf"
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Julik Tarkhanov"]
  s.date = "2012-01-10"
  s.description = "Stores marshaled temporary objects on-disk in a simple Enumerable"
  s.email = "me@julik.nl"
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".autotest",
    ".travis.yml",
    "Gemfile",
    "History.txt",
    "README.rdoc",
    "Rakefile",
    "lib/obuf.rb",
    "obuf.gemspec",
    "test/test_obuf.rb"
  ]
  s.homepage = "http://github.com/julik/obuf"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Ruby disk-backed object buffer"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<obuf>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<flexmock>, ["~> 0.8"])
    else
      s.add_dependency(%q<obuf>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<flexmock>, ["~> 0.8"])
    end
  else
    s.add_dependency(%q<obuf>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<flexmock>, ["~> 0.8"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<flexmock>, ["~> 0.8"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<flexmock>, ["~> 0.8"])
  end
end

