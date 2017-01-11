require 'rails_helper'

RSpec.describe FtpServiceController, type: :controller do
  describe 'POST #test' do
    it 'returns http success' do
      post :test
      expect(response).to have_http_status(:success)
    end

    context 'when given params[:asq]' do
      it 'calls FtpService.test' do
        expect(FtpService).to receive(:test)
        post :test, {"asq"=>{"direct_ftp_deliveries_attributes"=>{"0"=>{"host"=>"localhost", "port"=>"21", "directory"=>".", "username"=>"gmertzlufft", "password"=>"[FILTERED]"}}}}
      end
    end
  end
end
