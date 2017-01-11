# controller used for testing ftp connections via ajax
class SftpServiceController < ApplicationController
  protect_from_forgery with: :null_session

  # POST /sftp_service/test
  def test
    @test_results = test_sftp_service
    render json: @test_results
  end

  private

  def test_sftp_service
    begin
      credentials = params[:asq][:direct_sftp_deliveries_attributes]['0']
    rescue
      return { status: 'FAIL' }
    end
    SftpService.test(credentials, credentials[:directory])
  end
end
