Capistrano::Configuration.instance.load do
  set(:maintenance_source) do
    File.expand_path(File.dirname(__FILE__) + '/../assets/maintenance.html')
  end

  set(:maintenance_path)     { "#{shared_path}/system" }
  set(:maintenance_target)   { "#{maintenance_path}/maintenance.html"}

  namespace :maintenance do
    task :default do
      maintenance.on
    end

    desc "Enable maintenance mode"
    task :on, :roles => :web do
      on_rollback { run "rm -f #{maintenance_target}" }

      page = File.read(fetch(:maintenance_source))
      put page, fetch(:maintenance_target), :mode => 0644
    end

    desc "Disable maintenance mode"
    task :off, :roles => :web do
      run "rm -f '#{maintenance_target}'"
    end
  end

end