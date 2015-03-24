task :default => [:build]

task :build do
  `gem build ./ahalogy-automation.gemspec`
end

task :console do
  exec "irb -r ahalogy-automation -I ./lib"
end

task :run do
  ruby "-Ilib", 'bin/a5y-configure'
end
