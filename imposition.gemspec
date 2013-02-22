Gem::Specification.new do |s|
  s.name        = 'imposition'
  s.version     = '0.9.4.5.1'
  s.date        = '2013-02-22'
  s.summary     = "editorial imposition script in nUp & booklets"
  s.description = "nUp & booklets"
  s.authors     = ["Numerico"]
  s.email       = 'webmaster@numerica.cl'
  s.files       = Dir['lib/*']
  s.files       +=Dir['lib/imposition/*']
  s.add_runtime_dependency 'alchemist'
  s.add_runtime_dependency 'uuidtools'
  s.add_runtime_dependency 'fileutils'
  s.add_runtime_dependency 'i18n'
  s.add_development_dependency 'test/unit'
  s.executables << 'impostor'
  s.homepage    = 'http://impostor.herokuapp.com'
end