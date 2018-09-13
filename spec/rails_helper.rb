# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/poltergeist'
require 'devise'

Capybara.register_driver :poltergeist do |app|
  options = {
    # discard phantomjs log messages
    phantomjs_logger: File.open(File::NULL, 'w'),
    js_errors: false
  }
  Capybara::Poltergeist::Driver.new(app, options)
end

Capybara.server = :puma, { Silent: true }
Capybara.javascript_driver = :poltergeist
Capybara.server = :puma, { Silent: true }

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# Allows specs to be tagged with a feature name for exclusion unless feature
# enabled
RSpec.configure do |config|
  Rails.configuration.feature_settings.each do |name, enabled|
    config.filter_run_excluding name => !enabled
  end

  # Start up a Ladle LDAP server before running test suite if feature is enabled
  if Rails.configuration.feature_settings['ldap']
    config.before(:suite) do
      @ldap_server =
        Ladle::Server
        .new(quiet: true, ldif: 'spec/features/test_ldap_dir.ldif').start
    end

    config.after(:suite) do
      @ldap_server.stop if @ldap_server
    end
  end
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Used to clean out any underlying data that may not have been removed after
  # the test suite completes.
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation, except: %w(ar_internal_metadata)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
end

# Accepts a symbol and a value
# mock_settings(:my_url, 'http://goaway.example.com')
def mock_setting(setting, value = nil)
  allow(Settings).to receive(:method_missing)
    .with(setting, any_args)
    .and_return(value)
end
