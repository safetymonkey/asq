# controller used for testing ftp connections via ajax
class FtpServiceController < ApplicationController
  protect_from_forgery with: :null_session

  # POST /ftp_service/test
  def test
    @test_results = test_ftp_service
    render json: @test_results
  end

  private

  def test_ftp_service
    begin
      credentials = params[:asq][:direct_ftp_deliveries_attributes]['0']
    rescue
      return { status: 'FAIL' }
    end
    FtpService.test(credentials, credentials[:directory])
  end
end
