require 'rails_helper'

RSpec.describe FileOptions, type: :model do
  let(:options) { FileOptions.new }

  it 'destroys when default values are present.' do
    expect(options).to receive(:destroy)
    options.line_end = "\n"
    options.name = ''
    options.quoted_identifier = ''
    options.delimiter = ''
    options.save
  end

  it 'does not destroy when a non-defualt value for delimiter is present ' do
    expect(options).not_to receive(:destroy)
    options.line_end = "\n"
    options.delimiter = '|'
    options.save
  end

  it 'does not destroy when a none defualt value for quoted identifier is present ' do
    expect(options).not_to receive(:destroy)
    options.line_end = "\n"
    options.quoted_identifier = '\''
    options.save
  end

  it 'does not destroy when a none defualt value for name is present ' do
    expect(options).not_to receive(:destroy)
    options.line_end = "\n"
    options.name = 'PaperTest'
    options.save
  end

  it 'does not destroy when a none defualt value for line_end is present' do
    expect(options).not_to receive(:destroy)
    options.line_end = "\r\n"
    options.save
  end

  it 'destroys when escaped back slash is present (\\)' do
    expect(options).to receive(:destroy)
    options.line_end = "\\n"
    options.save
  end

end
