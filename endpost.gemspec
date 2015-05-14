Gem::Specification.new do |gem|
  gem.name        = 'endpost'
  gem.version     = '0.2.0'
  gem.date        = '2015-05-14'
  gem.summary     = 'A wrapper around Endicia web services.'
  gem.description = 'Allows to generate shipping labels and to perform some of the Endicia basic operations.'
  gem.license     = 'MIT'
  gem.authors     = ['Alfonso Cora']
  gem.email       = 'alfius@protonmail.com'
  gem.files       = `git ls-files -- lib/*`.split("\n")
  gem.homepage    = 'https://github.com/alfonsocora/endpost'

  gem.add_dependency 'rest-client', '~> 1.6', '>= 1.6.7'
  gem.add_dependency 'nokogiri', '~> 1.5', '>= 1.5.0'

  gem.add_development_dependency 'minitest', '~> 5.6', '>= 5.6.1'
  gem.add_development_dependency 'vcr', '~> 2.9', '>= 2.9.3'
end
