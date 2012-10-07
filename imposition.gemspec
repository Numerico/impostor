Gem::Specification.new do |s|
  s.name        = 'imposition'
  s.version     = '0.9.1'
  s.date        = '2012-08-16'
  s.summary     = "editorial imposition script"
  s.description = "nUp & booklets"
  s.authors     = ["Numerico"]
  s.email       = 'webmaster@numerica.cl'
  s.files       = Dir['lib/*']
  s.files       +=Dir['lib/imposition/*']
  s.add_runtime_dependency 'alchemist'
  s.add_runtime_dependency 'uuidtools'
  s.add_runtime_dependency 'fileutils'
  s.add_development_dependency 'test/unit'
  s.executables << 'impostor'
  s.homepage    = 'https://github.com/Numerico/impostor'
end