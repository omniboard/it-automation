require 'colorize'
require 'digest'
require 'fileutils'

def get_datadir
  datadir = Gem.datadir('files')
  datadir = File.join(File.dirname(__FILE__), '../../data/files') if datadir.nil?
  return datadir
end

def run_cmd(cmd, msg)
  puts msg
  puts "(cmd) '#{cmd}'".colorize(:blue)
  system cmd
  raise "Failed with exit code: #{$?}" if $? != 0
end

def install_brew(app, opts = '')
  if app.is_a? Array
    app.each { |a| install_brew a, opts }
    return
  end
  %x[brew list -1 | grep "^#{app}$" &> /dev/null]
  if $? == 0
    puts "(brew) updating #{app}...".colorize(:blue)
    system "brew upgrade #{app} #{opts}"
  else
    puts "(brew) install #{app} #{opts}".colorize(:blue)
    system "brew install #{app} #{opts}"
    raise "Failed with exit code: #{$?}" if $? != 0
  end
end

def uninstall_brew(app)
  if app.is_a? Array
    app.each { |a| uninstall_brew a }
    return
  end
  %x[brew list -1 | grep "^#{app}$" &> /dev/null]
  if $? != 0
    puts "(brew) #{app} is not installed...skipped.".colorize(:green)
  else
    puts "(brew-uninstall) uninstall #{app}".colorize(:blue)
    system 'brew', 'uninstall', '--force', app.to_s
    raise "Failed with exit code: #{$?}" if $? != 0
  end
end

def install_cask(app)
  if app.is_a? Array
    app.each { |a| install_cask a }
    return
  end
  %x[brew cask list #{app} &> /dev/null]
  if $? == 0
    puts "(cask) #{app} already installed...skipped.".colorize(:green)
  else
    puts "(cask) install #{app}".colorize(:blue)
    system 'brew', 'cask', 'install', app.to_s
    raise "Failed with exit code: #{$?}" if $? != 0
  end
end

def install_file(file, destination)
  file = File.join(get_datadir, file)
  if not File.readable? file
    puts "(file) Attempted to install #{file} but the file was not found.".colorize(:red)
    return false
  end
  destination = File.expand_path(destination)
  filemd5 = Digest::MD5.file(file).hexdigest
  destmd5 = ''
  if File.readable? destination
    destmd5 = Digest::MD5.file(destination).hexdigest
  end
  if filemd5 == destmd5
    puts "(file) #{file} and #{destination} are the same file...skipped.".colorize(:green)
  else
    puts "(file) Copying #{file} to #{destination}...".colorize(:blue)
    FileUtils.cp file, destination
  end
end

def add_line_to_file(file, line, regex = nil)
  regex = Regexp.escape(line) if regex == nil
  run_cmd "grep '#{regex}' #{file} --quiet || echo '#{line}' >> #{file}", "Updating #{file}..."
end

def mkdir(dir, mode: nil, owner: nil, group: nil)
  dir = File.expand_path dir
  if File.exists? dir
    if File.directory? dir
      puts "(mkdir) The directory #{dir} already exists...skipped.".colorize(:green)
    else
      fail "(mkdir) ERROR: Trying to create directory but file already exists at #{dir}".colorize(:red)
    end
  else
    puts "(mkdir) Creating directory #{dir}...".colorize(:blue)
    FileUtils.mkdir_p dir
  end
  FileUtils.chmod mode, dir unless mode.nil?
  FileUtils.chown owner, group, dir
end
