require "bundler/capistrano"
load 'deploy/assets'

set :application, "miaomiaocat"
set :repository, "git://github.com/sg552/miaomiaocat.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "sg552sg552.oicp.net"                          # Your HTTP server, Apache/etc
role :app, "sg552sg552.oicp.net"                          # This may be the same as your `Web` server
role :db,  "sg552sg552.oicp.net", :primary => true # This is where Rails migrations will run

set :deploy_to, "/home/sg552/workspace/miaomiaocat"
set :user, "sg552"
set :password, "sss333"
#ssh_options[:keys] = %w{connectingbj.pem}

namespace :deploy do
  set :use_sudo, true
  task :restart do
    #run "/opt/nginx/sbin/nginx -s reload"
    run "touch tmp/restart.txt"
  end
  task :start do
    run "/opt/nginx/sbin/nginx"
  end
  task :stop do
    run "/opt/nginx/sbin/nginx -s stop"
  end
  namespace :assets do
    task :precompile do
      run "cd #{release_path} && bundle exec rake RAILS_ENV=production RAILS_GROUPS=assets assets:precompile RAILS_RELATIVE_URL_ROOT='/fangziya'"
    end
  end
end


# store the database.yml and other configuration files in the
# common shared directory and then copy them in to the application
desc "Copy database.yml to release_path"
task :cp_database_yml do
  puts "executing my customized command: "
  puts "cp -r #{shared_path}/config/* #{release_path}/config/"
  run "cp -r #{shared_path}/config/* #{release_path}/config/"
end

before "deploy:assets:symlink", :cp_database_yml

#before "deploy", mongrel::stop
