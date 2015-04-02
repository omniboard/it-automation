Gem::Specification.new do |gem|
  gem.name        = 'ahalogy-automation'
  gem.version     = '0.0.1'
  gem.date        = '2015-03-23'
  gem.summary     = 'Scripts to handle IT automation.'
  gem.authors     = ['Zan Loy']
  gem.files       = `git ls-files`.split("\n") - %w[.gitignore]
  gem.executables = ['a5y-configure']

  gem.add_runtime_dependency 'colorize', '~> 0'
  gem.add_runtime_dependency 'github', '~> 0'
end
