class DatabaseTesterController < ApplicationController
  protect_from_forgery with: :null_session

  # GET /db_test
  def index
    @test_results = 'Nothing to see here.'
    render json: @test_results
  end

  # POST /db_test
  def test
    @test_results = DatabaseTester.test_database(
      params[:database][:hostname],
      params[:database][:username],
      params[:database][:password],
      params[:database][:port],
      params[:database][:db_type],
      params[:database][:db_name]
    )

    render json: @test_results
  end
end
