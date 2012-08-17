Gem::Specification.new do |s|
  s.name        = 'imposition'
  s.version     = '0.8.8.alpha'
  s.date        = '2012-08-16'
  s.summary     = "editorial imposition script"
  s.description = "nUp & booklets"
  s.authors     = ["Numerico"]
  s.email       = 'webmaster@numerica.cl'
  s.files       = Dir['lib/*']
  s.files       +=Dir['lib/imposition/*']
  s.executables << 'impostor'
  s.homepage    = 'https://github.com/Numerico/impostor'
end