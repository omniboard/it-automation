task :default => [:build]
task :test => [:build, :install]

task :build do
  `gem build ./ahalogy-automation.gemspec`
end

task :install do
  gem = Dir['*.gem'].last
  `sudo gem install #{gem}`
end

task :push do
  gem = Dir['*.gem'].last
  `gem push #{gem}`
end

task :console do
  exec "irb -r ahalogy-automation -I ./lib"
end

task :run do
  ruby "-Ilib", 'bin/a5y-configure'
end
