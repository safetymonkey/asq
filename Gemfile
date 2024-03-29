source 'http://rubygems.org'
ruby '2.7.5'
require 'yaml'

features = YAML.load_file(File.expand_path('../config/features.yml', __FILE__))

gem 'ruby-oci8', '~> 2.2.3' if features['oracle_db']
gem 'mysql2', '~> 0.4.5' if features['mysql_db']

gem 'devise_ldap_authenticatable', '~> 0.8.5'

gem "actionpack", "5.2.6.2"
gem "activerecord", "5.2.6.2"
gem "activesupport", "5.2.6.2"
gem "railties", "5.2.6.2"

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
gem 'devise', '~> 4.7.1'
gem 'execjs', '~> 2.7.0'
gem 'fun_sftp'
gem 'gon', '~> 6.4.0'
gem 'graphite-api', '0.1.8'
gem 'jbuilder', '~> 2.7.0'
gem 'json-stream'
gem 'momentjs-rails', '>= 2.9.0'
gem 'net-sftp'
gem 'net-ssh'
gem 'oj', '~> 3.5.0'
gem 'oj_mimic_json'
gem 'paper_trail', '~> 12.1.0'
gem 'pg', '~> 1.2.3'
gem 'puma', '~> 5.6.2'
gem 'rails', '5.2.6.2'
gem 'redcarpet', '~> 3.5.1'
gem 'responders', '~> 2.4.0'
gem 'rest-client', '~> 2.0.2'
gem 'roadie-rails', '~> 2.3.0'
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
  gem 'rails_real_favicon', '~> 0.1.1'
  gem 'thin', '~> 1.8.1'
  gem 'yaml_db', '~> 0.7.0'
end

group :development, :test do
  gem 'ci_reporter'
  gem 'ci_reporter_rspec'
  gem 'factory_bot_rails', '5.2.0'
  gem 'faker', '~> 2.19.0'
  gem 'jasmine'
  gem 'phantomjs'
  gem 'rspec-rails', '~> 3.1'
  gem 'rubocop'
  gem 'rubocop-checkstyle_formatter', require: false
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'jasmine_junitxml_formatter'
  gem 'ladle'
  # gem 'memory_test_fix', '~> 1.5.1'
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
