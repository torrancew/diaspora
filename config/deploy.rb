#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

set :config_yaml, YAML.load_file(File.dirname(__FILE__) + '/deploy_config.yml')

require './config/cap_colors'
require 'bundler/capistrano'
require './config/boot'
require 'hoptoad_notifier/capistrano'
set :bundle_dir, ''

set :stages, ['production', 'staging']
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

set :application, 'diaspora'
set :scm, :git
set :use_sudo, false
set :scm_verbose, true
set :repository_cache, "remote_cache"
set :deploy_via, :checkout

# Figure out the name of the current local branch
def current_git_branch
  branch = `git symbolic-ref HEAD 2> /dev/null`.strip.gsub(/^refs\/heads\//, '')
  logger.info "Deploying branch #{branch}"
  branch
end

namespace :deploy do
  task :symlink_config_files do
    run "ln -s -f #{shared_path}/config/database.yml #{current_path}/config/database.yml"
    run "ln -s -f #{shared_path}/config/application.yml #{current_path}/config/application.yml"
    run "ln -s -f #{shared_path}/config/oauth_keys.yml #{current_path}/config/oauth_keys.yml"
  end

  task :symlink_cookie_secret do
    run "ln -s -f #{shared_path}/config/initializers/secret_token.rb #{current_path}/config/initializers/secret_token.rb"
  end

  task :bundle_static_assets do
    run "cd #{current_path} && sass --update public/stylesheets/sass:public/stylesheets"
    run "cd #{current_path} && bundle exec jammit"
  end

  task :restart do
    run 'sv restart resque'
    run 'sv restart diaspora'
  end

  task :kill do
    run 'sv kill resque'
    run 'sv kill diaspora'
  end

  task :start do
    run 'sv start resque'
    run 'sv start diaspora'
  end

  task :stop do
    run 'sv stop resque'
    run 'sv stop diaspora'
  end

  desc 'Copy resque-web assets to public folder'
  task :copy_resque_assets do
    target = "#{release_path}/public/resque-jobs"
    run "cp -r `cd #{release_path} && bundle show resque`/lib/resque/server/public #{target}"
  end
end

before 'deploy:update' do
  set :branch, current_git_branch
end

after 'deploy:symlink' do
  deploy.symlink_config_files
  deploy.symlink_cookie_secret
  deploy.bundle_static_assets
  deploy.copy_resque_assets
end

