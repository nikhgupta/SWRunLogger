# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'swarlogs'
set :repo_url, 'https://github.com/nikhgupta/SWRunLogger'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/rails/swarlogs'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
set :pty, false # known bug with capistrano-sidekiq - keep it false!

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml', 'config/secrets.yml', 'config/sidekiq.yml'
)

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle',
  'public/system', 'data'
)

# Default value for default_env is {}
set :default_env, {
  rails_env: :production, rack_env: :production,
  rvm_bin_path: "/usr/local/rvm/bin/rvm"
}

# Default value for keep_releases is 5
set :keep_releases, 5

# rails
set :keep_assets, 2
set :assets_roles, [:web, :app]

# sidekiq
set :sidekiq_config, File.join(shared_path, "config", "sidekiq.yml")
set :sidekiq_processes, 1

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      execute "source /etc/default/unicorn; sudo service unicorn restart"
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after  :finishing, 'deploy:cleanup'
  before :finishing, 'deploy:restart'
  after  :rollback,  'deploy:restart'
end
