require_relative 'lib/obuf'

Gem::Specification.new do |s|
  s.name = "obuf"
  s.version = Obuf::VERSION
  s.authors = ["Julik Tarkhanov"]
  s.email = "me@julik.nl"
  s.summary = "Ruby disk-backed object buffer"
  s.description = "Stores marshaled temporary objects on-disk in a simple Enumerable"
  s.homepage = "https://github.com/julik/obuf"
  s.licenses = ["MIT"]
  s.extra_rdoc_files = ["README.md"]
  s.files = Dir["lib/**/*.rb"] + %w(History.txt README.md)
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 2.6"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "flexmock"
end
