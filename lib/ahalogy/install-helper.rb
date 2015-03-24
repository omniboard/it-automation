require 'fileutils'

def get_datadir
  datadir = Gem.datadir('ahalogy-automation')
  datadir = File.join(File.dirname(__FILE__), '../../data/ahalogy-automation') if datadir== nil
  return datadir
end

def run_cmd(cmd, msg)
  puts msg
  puts "(cmd) '#{cmd}'" #DEBUG
  results = system(cmd)
  abort "FAILED." if $? != 0
end

def install_brew(app)
  %x[brew list #{app}]
  if $? == 0
    puts "(brew) #{app} already installed...skipped."
  else
    puts "(brew) install #{app}"
    system 'brew', 'install', app
    abort "FAILED." if $? != 0
  end
end

def install_cask(app)
  %x[brew cask list #{app}]
  if $? == 0
    puts "(cask) #{app} already installed...skipped."
  else
    puts "(cask) install #{app}"
    system 'brew', 'cask', 'install', app
    abort "FAILED." if $? != 0
  end
end

def install_file(file, destination)
  file = File.join(get_datadir, file)
  if not File.readable? file
    puts "(file) Attempted to install #{file} but the file was not found."
    return false
  end
  destination = File.expand_path(destination)
  puts "(file) Copying #{file} to #{destination}..."
  FileUtils.cp file, destination
end

def add_line_to_file(file, line, regex = nil)
  regex = Regexp.escape(line) if regex == nil
  run_cmd "grep '#{regex}' #{file} --quiet || echo '#{line}' >> #{file}", "Updating #{file}..."
end
