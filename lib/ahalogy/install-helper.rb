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

def add_line_to_file(file, line, regex = nil)
  regex = Regexp.escape(line) if regex == nil
  run_cmd "grep '#{regex}' #{file} --quiet || echo '#{line}' >> #{file}", "Updating #{file}..."
end
