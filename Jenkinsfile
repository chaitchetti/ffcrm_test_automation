pwd
whoami

# Load RVM environment
. /home/admin/.rvm/scripts/rvm

export PATH=$PATH:/home/admin/.rvm/rubies/ruby-3.3.0/bin
export GEM_HOME=/var/lib/jenkins/gems
export PATH=$GEM_HOME/bin:$PATH
export PATH=/var/lib/jenkins/gems/bin:$PATH

# Install bundler
gem install bundler

cd /var/lib/jenkins/workspace/ffcrm_tests
# Install dependencies using Bundler
bundle install
export PATH=$PATH:/var/lib/jenkins/gems/bin/bundle

ruby --version
ls -l

gem list selenium-webdriver
bundle exec ruby ffcrm_CRUD_automation_with_config.rb
