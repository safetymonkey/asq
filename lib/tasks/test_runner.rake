# The LoadError rescue is required to prevent a build fail in Pulley.
# Running "rake assets:precompile" (specified in pulley comp) following a
# "bundle install --without test development" (also in pulley conf) causes this
# file to execute, and fail to load rspec/core/rake_task because rspec hassn't
# been loaded. Pulley error below.

# /site/ruby/ruby-2.1/bin/bundle exec rake assets:precompile --trace
# rake aborted!
# LoadError: cannot load such file -- rspec/core/rake_task

begin
  require 'rspec/core/rake_task'
  require 'ci/reporter/rake/rspec'
rescue LoadError
  puts 'LoadError rescued in test_runner.rake'
end

task default: :spec
