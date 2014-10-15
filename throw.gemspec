Gem::Specification.new do |s|
  s.name           = 'throw'
  s.version        = '0.0.1'
  s.date           = '2014-10-14'
  s.summary        = 'CouchDB simple wrapper'
  s.description    = 'A simple CouchDB API wrapper'
  s.authors        = ['Matías Aguirre']
  s.email          = 'matiasaguirre@gmail.com'
  s.files          = `git ls-files`.split($/)
  s.executables    = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.add_dependency 'rest-client', '~> 1.7'
  s.homepage       = 'https://github.com/omab/throw'
  s.license        = 'MIT'
end
