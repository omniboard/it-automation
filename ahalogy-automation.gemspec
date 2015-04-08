Gem::Specification.new do |gem|
  gem.name        = 'ahalogy-automation'
  gem.version     = '0.0.2'
  gem.licenses    = ['MIT']
  gem.date        = '2015-03-23'
  gem.summary     = 'Scripts to handle IT automation.'
  gem.description = 'Script that installs many applications on Ahalogy Mac computers.'
  gem.authors     = ['Zan Loy']
  gem.email       = 'zan.loy@gmail.com'
  gem.homepage    = 'https://www.ahalogy.com'
  gem.files       = `git ls-files`.split("\n") - %w[.gitignore]
  gem.executables = ['a5y-configure']

  gem.add_runtime_dependency 'colorize', '~> 0'
  gem.add_runtime_dependency 'github', '~> 0'
end
