Gem::Specification.new do |s|
  s.name        = 'panda_api'
  s.version     = '0.0.4'
  s.date        = '2020-09-10'
  s.summary     = "PandaDoc API"
  s.description = "Wrapper for PandaDoc API"
  s.authors     = ["Matt Deatherage"]
  s.email       = 'matt.deatherage@pandadoc.com'
  s.files       = ["lib/panda_api.rb"]
  s.homepage    =
    'https://rubygems.org/gems/panda_api'
  s.license       = 'MIT'
  s.add_development_dependency 'faraday_middleware'
  s.add_runtime_dependency 'faraday_middleware'
  s.add_development_dependency 'httparty'
  s.add_runtime_dependency 'httparty'
  s.add_development_dependency 'launchy'
  s.add_runtime_dependency 'launchy'
  s.add_development_dependency 'activesupport'
  s.add_runtime_dependency 'activesupport'
  s.add_development_dependency 'uri'
  s.add_runtime_dependency 'uri'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'fillable-pdf'
end
