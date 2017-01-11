require 'rails_helper'

RSpec.describe 'Settings' do
  # See Settings.rb for why this is a thing.

  before(:example) do
    Delayed::Worker.max_run_time = 3000
  end

  describe '.max db timeout default' do
    context 'while max_db_timeout - 60 > max_db_timeout * .95' do
      it 'max_db_timeout is set to (-60 seconds) is greater then 95 percent' do
        expected_results = 2940
        results = Settings.max_db_timeout

        expect(results).to eq(expected_results)
      end
    end
    context 'while max_db_timeout - 60 < max_db_timeout * .95' do
      it 'max_db_timeout is set to (-60 seconds) is greater then 95 percent' do
        Delayed::Worker.max_run_time = 10
        expected_results = 9.5
        results = Settings.max_db_timeout

        expect(results).to eq(expected_results)
      end
    end
  end

  it 'invokes method_missing when passed a setting' do
    expect(Settings).to receive(:method_missing)
    Settings.result_limit
  end

  # Granted, it's weird that we're testing a spec implemntation of a default
  # value. But it's what we've got. And since you can consider those
  # defaults to be part of the code itself, then this test is, technically,
  # testing the code. As of this writing, the default result limit is 5000.
  it 'gets a default value when asked for a setting that has one' do
    expect(Settings.result_limit).to eq(5000)
  end
  it 'gets a single whitespace character when asked for a non-existant setting with no default' do
    expect(Settings.random_thing).to eq('')
  end

  it 'gets an empty string when a value is present, yet blank' do
    Settings.random_thing = ''
    expect(Settings.random_thing).to eq('')
  end

  it 'returns false when a false value is present' do
    Settings.false_setting = 'false'
    expect(Settings.false_setting).to be_falsey
  end

  it 'stores the value of a new setting, and properly returns that value' do
    Settings.random_thing = 10000
    expect(Settings.random_thing).to eq(10000)
  end
end