Gem::Specification.new do |gem|
  gem.name        = 'ahalogy-automation'
  gem.version     = '0.0.8'
  gem.licenses    = ['MIT']
  gem.date        = '2015-06-26'
  gem.summary     = 'Scripts to handle IT automation.'
  gem.description = 'Scripts that install applications on Ahalogy Mac computers.'
  gem.authors     = ['Zan Loy', 'Brian Cerchio']
  gem.email       = ['zan.loy@gmail.com', 'brian.cerchio@gmail.com']
  gem.homepage    = 'https://www.ahalogy.com'
  gem.files       = `git ls-files`.split("\n") - %w[.gitignore]
  gem.executables = ['a5y-configure']

  gem.add_runtime_dependency 'colorize', '~> 0'
  gem.add_runtime_dependency 'command', '~> 1.0.0', '>= 1.0.0'
  gem.add_runtime_dependency 'daybreak', '~> 0.3', '>= 0.3.0'
  gem.add_runtime_dependency 'github_api', '~> 0.12', '>= 0.12.3'
  gem.add_runtime_dependency 'highline', '~> 1.7'
end
