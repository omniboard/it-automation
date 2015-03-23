#!/usr/bin/ruby

require 'optparse'
require 'pp'

groups = ['developer', 'pinner', 'cs', 'marketing', 'content']
options = {
  :groups => ['default'],
  :verbose => false,
}
OptionParser.new do |opts|
  groups.each do |group|
    opts.on("--#{group}", "Install apps for #{group} group.") { options[:groups] << group }
  end
  opts.on("-l", "--list", "List available groups.") do
    puts "Available groups: #{groups.join(', ')}"
    exit
  end
  opts.on("-d", "--debug", "Enable debug messaging.") { options[:verbose] = true }
end.parse!

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

cleanup = []

if options[:groups].include? 'default'
  ## Install xcode command line tools
  system("xcode-select -v")
  if $? != 0
    run_cmd "xcode-select --install", "Installing Xcode."
  else
    puts "Xcode is already installed...skipped."
  end

  # Let's setup our sshkey and github (we need this to pull the config repo)
  if File.exists? File.expand_path("~/.ssh/id_rsa")
    puts "sshkey exists... skipped."
  else
    run_cmd "ssh-keygen -f ~/.ssh/id_rsa -N ''", "Generating sshkey."
  end

  # Enable FileVault
  # run_cmd "sudo fdesetup enable -user admin -usertoadd enduser"

  # Enable system firewall
  run_cmd "sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1", "Enabling firewall."

  # Install homebrew
  if File.exists? '/usr/local/bin/brew'
    puts "Homebrew already installed...skipped."
  else
    run_cmd 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"', "Installing homebrew."
  end

  # Tap casks
  run_cmd 'brew tap caskroom/cask', "Tapping caskroom/cask..."
  run_cmd 'brew tap caskroom/fonts', "Tapping caskroom/fonts..."
  run_cmd 'brew tap caskroom/versions', "Tapping caskroom/versions..."
  run_cmd 'brew tap homebrew/dupes', "Tapping homebrew/dupes..."
  run_cmd 'brew tap homebrew/versions', "Tapping homebrew/versions..."

  ### Install Applications
  install_cask 'backblaze' # Will require cleanup task to run installer.
  install_brew 'git' # No further configuration required.
  install_cask 'github' # Configuration will occur on first run of application.
  install_cask 'google-chrome' # No further configuration required.
  install_cask 'google-drive' # Configuration will occur on first run of application.
  install_cask 'macvim'
  install_cask 'screenhero' # Configuration will occur on first run of application.
  install_cask 'textmate'
  install_cask 'zoomus' # Configuration will occur on first run of applicaiton.
  
  # Run BackBlaze Installer
  cleanup << %q[run_cmd "open -a '/opt/homebrew-cask/Caskroom/backblaze/latest/Backblaze Installer.app'", "Installing BackBlaze."]
end # options[:groups] = default

if options[:groups].include? 'developer'
  puts "### Starting installation of developer apps... ###"
  install_cask '1password' # Configuration will occur on first run of application.
  install_cask 'alfred' # Configuration will occur on first run of application.
  install_cask 'anvil'
  install_brew 'python'
  install_brew 'python3'
  install_brew 'cassandra'
  run_cmd 'pip install cql &> /dev/null', 'Installing cql python module via pip...'
  run_cmd 'pip3 install cql &> /dev/null', 'Installing cql python3 module via pip3...'
  install_cask 'dash'
  install_brew 'node'
  install_brew 'phantomjs'
  install_brew 'homebrew/versions/postgresql92'
  install_brew 'pow'
  install_brew 'rbenv'
  install_brew 'redis'
  install_brew 'ruby-build'
  install_cask 'slack'
  install_cask 'tower'
  # Configure pow
  if not File.directory? File.expand_path('~/Library/Application Support/Pow/Hosts')
    run_cmd 'mkdir -p ~/Library/Application\ Support/Pow/Hosts', 'Creating support directory for pow hosts...'
  end
  if not File.symlink? File.expand_path('~/.pow')
    run_cmd 'ln -s ~/Library/Application\ Support/Pow/Hosts ~/.pow', 'Symlinking pow hosts directory to ~/.pow ...'
  end
  run_cmd 'sudo pow --install-system', 'Configuring port 80 forwarding for pow...'
  run_cmd 'pow --install-local', 'Configuring launchd agent for pow...'
  run_cmd 'sudo launchctl load -w /Library/LaunchDaemons/cx.pow.firewall.plis', 'Configuring pow launchd agent to start on boot...'
  run_cmd 'launchctl load -w ~/Library/LaunchAgents/cx.pow.powd.plist', 'Starting pow...'
  # Configure rbenv
  system("grep -q -F 'export RBENV_ROOT=/usr/local/var/rbenv' /etc/profile")
  if $? != 0
    run_cmd "echo 'export RBENV_ROOT=/usr/local/var/rbenv' | sudo tee -a /etc/profile > /dev/null", "Adding RBENV_ROOT to /etc/profile..."
  end
  system("grep -q -F 'rbenv init -' /etc/profile")
  if $? != 0
    run_cmd %q[echo 'eval "$(rbenv init -)"' | sudo tee -a /etc/profile > /dev/null], "Adding rbenv init to /etc/profile..."
  end
  Dir.mkdir '/usr/local/var/rbenv/plugins' if not Dir.exists? '/usr/local/var/rbenv/plugins'
  if File.exists? '/usr/local/var/rbenv/plugins/rbenv-gem-rehash'
    puts 'rbenv-gem-rehash already installed...skipped.'
  else
    run_cmd 'sudo git clone https://github.com/sstephenson/rbenv-gem-rehash.git /usr/local/var/rbenv/plugins/rbenv-gem-rehash', "Installing rbenv-gem-rehash..."
  end
  # OH MY ZSH!
  if not File.directory? File.expand_path('~/.oh-my-zsh')
    run_cmd "curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh", "Installing oh-my-zsh..."
  end
end # options[:groups] = developer

if not cleanup.empty?
  cleanup.each do |cmd|
    puts "(cleanup) #{cmd}"
  end
end
