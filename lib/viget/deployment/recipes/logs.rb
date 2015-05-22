# via: https://exceptiontrap.com/blog/6-tail-your-remote-logs-with-capistrano

namespace :logs do
  desc "tail environment log files"
  task :tail, roles: :app do
    file = fetch(:file, fetch(:stage).to_s)     # handles passed in filename or specified stage

    trap("INT") { puts "Interrupted"; exit 0; } # handles capturing ctrl+c to exit

    run "tail -f #{shared_path}/log/#{file}.log" do |channel, stream, data|
      puts # extra line break before the host name
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end
end
