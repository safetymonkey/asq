require 'rails_helper'

RSpec.describe ArchivedFilesController, type: :controller do
  describe '.show' do
    let(:file) { FactoryGirl.create(:archived_file) }
    let(:send_options) do
      { type: 'text/csv; charset=utf-8; header=present',
        disposition: "attachment; filename=\"#{file.name}\"" }
    end

    before(:example) do
      allow(controller).to receive(:send_file)
        .with(file.full_path, send_options) {
          @controller.render body: nil
        }
    end

    it 'sets @file to correct file' do
      get :show, params: { id: file.id }
      expect(assigns(:file)).to eq(file)
    end

    it 'send file' do
      # this is how to test that send_file is called with the correct params
      expect(controller).to receive(:send_file)
        .with(file.full_path, send_options) {
          @controller.render body: nil
        }
      get :show, params: { id: file.id }
    end

    context 'while file does not exist' do
      before(:example) do
        allow(controller).to receive(:send_file).and_raise('BOOM')
      end
      it 'logs error' do
        expect(Rails.logger).to receive(:error)
        get :show, params: { id: file.id }
      end
    end
  end
end
