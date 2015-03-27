task :default => [:build, :install]

task :build do
  `gem build ./ahalogy-automation.gemspec`
end

task :install do
  gems = Dir['*.gem']
  `sudo gem install #{gems.first}`
end

task :console do
  exec "irb -r ahalogy-automation -I ./lib"
end

task :run do
  ruby "-Ilib", 'bin/a5y-configure'
end
