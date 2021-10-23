server 'piped-deploy', port: 22, roles: [:web, :app, :db], primary: true
set :application, 'piped'
set :repo_url, 'git@github.com:IvRRimum/Piped.git'
set :branch, 'local'
set :user,            'deploy'
set :console_user, 'deploy'
set :ssh_options,     { 
  forward_agent: true,
  user: fetch(:user),
  keys: %w(~/.ssh/piped-deploy),
  auth_methods: %w(publickey)
}
set :pty,             false
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/#{fetch(:application)}"

set :linked_dirs,  %w{log node_modules}

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse private/local`
        puts "WARNING: HEAD is not the same as private/local"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc "Generate a new distribution version"
  task :generate_dist_version do

    on roles(:app) do
      execute "cd #{release_path} && yarn install && yarn build"
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :generate_dist_version
end
