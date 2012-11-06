# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'file_cache/version'

Gem::Specification.new do |gem|
  gem.name          = "file_cache"
  gem.version       = FileCache::VERSION
  gem.authors       = ["Maximilian Haack"]
  gem.email         = ["mxhaack@gmail.com"]
  gem.description   = %q{A simple way to cache your files.}
  gem.summary       = %q{Cache files that you have have to use several times.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
end
