source 'http://rubygems.org'
ruby '2.3.8'
require 'yaml'

features = YAML.load_file(File.expand_path('../config/features.yml', __FILE__))

gem 'ruby-oci8', '~> 2.2.3' if features['oracle_db']
gem 'mysql2', '~> 0.4.5' if features['mysql_db']

gem 'devise_ldap_authenticatable', '~> 0.8.5'

gem 'acts-as-taggable-on', '~> 5.0.0'
gem 'autoprefixer-rails', '~> 8.2.0'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.43'
gem 'browser'
gem 'cancancan', '2.1.3' # Changed this from cancan, may need to roll back
gem 'coffee-rails', '~> 4.2.1'
gem 'crypt_keeper', '~> 2.0.0.rc2'
gem 'daemons'
gem 'delayed_job_active_record', '~> 4.1.2'
gem 'devise', '~> 4.4.3'
gem 'execjs', '~> 2.7.0'
gem 'fun_sftp'
gem 'gon', '~> 6.2.0'
gem 'graphite-api', '0.1.8'
gem 'jbuilder', '~> 2.7.0'
gem 'json-stream'
gem 'momentjs-rails', '>= 2.9.0'
gem 'net-sftp'
gem 'net-ssh'
gem 'oj', '~> 3.5.0'
gem 'oj_mimic_json'
gem 'paper_trail', '~> 8.1.2'
gem 'pg', '~> 1.0.0'
gem 'puma'
gem 'rails', '~> 5.1.5'
gem 'redcarpet', '~> 3.4.0'
gem 'responders', '~> 2.4.0'
gem 'rest-client', '~> 2.0.2'
gem 'roadie-rails', '~> 1.2.1'
gem 'sass-rails', '~> 5.0.6'
gem 'uglifier', '~> 4.1.8'
gem 'will_paginate', '~> 3.1.5'
gem 'will_paginate-bootstrap'

group :doc do
  gem 'sdoc', '~> 1.0.0'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', platforms: [:mri_19, :mri_20, :rbx]
  gem 'rails_layout'
  gem 'rails_real_favicon'
  gem 'thin'
  gem 'yaml_db'
end

group :development, :test do
  gem 'ci_reporter'
  gem 'ci_reporter_rspec'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'jasmine'
  gem 'phantomjs'
  gem 'rspec-rails', '~> 3.1'
  gem 'rubocop'
  gem 'rubocop-checkstyle_formatter', require: false
end

group :test do
  gem 'capybara'
  gem 'codecov', require: false
  gem 'database_cleaner'
  gem 'jasmine_junitxml_formatter'
  gem 'ladle'
  gem 'memory_test_fix', '~> 1.5.1'
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'sqlite3'
end

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end
