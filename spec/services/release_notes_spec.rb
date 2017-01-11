require 'rails_helper'

RSpec.describe ReleaseNotes do
  let(:file_list) { ['20151016-this-is-a-release-note.md',
                     '20151023-this-is-also-a-release.md', '20151001-README-FIRST.md'] 
                  }
  let(:empty_file_list) { [] }
  let(:release_notes) { ReleaseNotes.new(0) }

  it 'initializes with integer' do
    release_notes = ReleaseNotes.new(3)
    expect(release_notes).to be_a(ReleaseNotes)
  end

  it 'raises exception with non-integer initialization' do
    expect { ReleaseNotes.new('TUESDAY') }.to raise_error(ArgumentError)
  end

  it 'reads in a list of files in the relase notes directory' do
    allow(Dir).to receive(:glob).and_return(file_list)
    expect(release_notes.notes.length).to eq(3)
  end

  it 'ignores previously read messages' do
    allow(Dir).to receive(:glob).and_return(file_list)
    release_notes = ReleaseNotes.new(20151016)
    i = 0
    release_notes.notes.each do |note|
      i += 1 if note[:unread]
    end
    expect(i).to eq(1)
  end

  it 'knows that it has updates' do
    allow(Dir).to receive(:glob).and_return(file_list)
    expect(release_notes.has_notes?).to be_truthy
  end

  it 'knows that it doesn\'t have updates' do
    allow(Dir).to receive(:glob).and_return(file_list)
    release_notes = ReleaseNotes.new(20151023)
    expect(release_notes.has_notes?).to be_falsy
  end

  it 'returns notes as an array' do
    allow(Dir).to receive(:glob).and_return(file_list)
    expect(release_notes.notes).to be_an(Array)
  end
end
