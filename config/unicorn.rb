rails_env = ENV['RAILS_ENV'] || 'production'

#worker_processes (rails_env == 'production' ? 16 : 4)
worker_processes 3

## Load the app before spawning workers
#preload_app true

# How long to wait before killing an unresponsive worker
timeout 30

#pid '/var/run/diaspora/diaspora.pid'
#listen '/var/run/diaspora/diaspora.sock', :backlog => 2048

# Ruby Enterprise Feature
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end


before_fork do |server, worker|
  old_pid = '/var/run/diaspora/diaspora.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end


after_fork do |server, worker|
  ##
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection
#  ActiveRecord::Base.establish_connection

  # Unicorn master may be started as root, which is fine, but let's
  # drop the workers to diaspora:diaspora
  begin
    uid, gid = Process.euid, Process.egid
    user, group = 'diaspora', 'diaspora'
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid
    worker.tmp.chown(target_uid, target_gid)
    if uid != target_uid || gid != target_gid
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue => e
    if RAILS_ENV == 'development'
      STDERR.puts "Hmmm... Unicorn couldn't change the user.  Oh well - it's just a dev environment..."
    else
      raise e
    end
  end
end
