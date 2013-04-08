Capistrano::Configuration.instance.load do
  set(:bundle_flags, '--deployment --quiet --binstubs')
end