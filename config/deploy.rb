# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'es-twitter-stream'
set :repo_url, 'git@github.com:pokutuna/es-twitter-stream.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/deploy/apps/es-twitter-stream'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('vendor', '.bundle')

# Default value for default_env is {}
set :default_env, { path: "/usr/local/xbuild/ruby-2.3.0/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :supervisor_user, 'deploy'
set :supervisor_server_confd, '/etc/supervisor/conf.d/'
set :supervisor_conf_path, 'config/es-twitter-stream.supervisord.conf'
load 'modules/pokloy-recipes/recipes/supervisor.rb'

namespace :deploy do

  task :bundler do
    on roles(:app) do
      within release_path do
        execute :bundle, 'install --path vendor/bundle'
      end
    end
  end
  after :published, :bundler

  task :restart do
    on roles(:app) do
      invoke 'supervisor:restart_app'
    end
  end
  after :finishing, :restart
end

task :setup do
  on roles(:app) do
    upload! 'config.yml', "#{shared_path}/config.yml"
    invoke 'deploy:check:linked_files'
    invoke 'supervisor:setup'
  end
end
