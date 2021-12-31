require 'rails_helper'
RSpec.describe ArchivedFile, type: :model do
  let(:archived_file) { FactoryBot.build(:archived_file, id: 99) }

  before(:example) do
    allow(Dir).to receive(:mkdir)
    allow(File).to receive(:exists?)
    allow(File).to receive(:delete)
    allow(File).to receive(:open)
  end

  describe '.write' do
    context 'while archive folder does not exist' do
      before(:example) do
        allow(File).to receive(:exist?)
          .with(Rails.application.archive_file_dir)
          .and_return(false)
      end
      it 'creates archive directory' do
        expect(Dir).to receive(:mkdir).with(Rails.application.archive_file_dir)
        archived_file.write('test')
      end
    end

    context 'while archive folder does exist' do
      before(:example) do
        @file = double
        @content = Faker::Lorem.words(number: 20).join(' ')
        @path = archived_file.full_path
        allow(File).to receive(:open).with(@path, 'w:UTF-8').and_yield(@file)
        allow(@file).to receive(:write)
      end

      it 'saves file to correct directory' do
        expect(File).to receive(:open).with(@path, 'w:UTF-8')
        archived_file.write(@content)
      end

      it 'saves file with correct contents' do
        expect(@file).to receive(:write).with(@content)
        archived_file.write(@content)
      end
    end

    context 'while exception is thrown' do
      it 'logs error' do
        allow(File).to receive(:open).and_raise('BOOM')
        expect(Delayed::Worker.logger).to receive(:error)
        archived_file.write(@content)
      end
    end
  end

  describe '.full_path' do
    it 'generates correct path' do
      # for id = 99
      target_name = '0000000099.dat'
      target_dir = Rails.application.archive_file_dir
      path = File.join(target_dir, target_name)
      expect(archived_file.full_path).to eq(path)
    end
  end

  describe '.destroy' do
    it 'deletes file' do
      expect(File).to receive(:delete).with(archived_file.full_path)
      archived_file.destroy
    end

    context 'while an exception is thrown' do
      it 'logs the error' do
        allow(File).to receive(:delete).and_raise('BOOM')
        expect(Rails.logger).to receive(:error)
        archived_file.destroy
      end
    end
  end

  describe '.create' do
    before(:example) do
      @file = double
      @content = Faker::Lorem.words(number: 20).join(' ')
      allow(File).to receive(:open).and_yield(@file)
      allow(@file).to receive(:write)
    end
    it 'writes content to file' do
      expect(@file).to receive(:write).with(@content)
      ArchivedFile.create(name: 'garbage.txt', content: @content)
    end
  end
end
