require 'rails_helper'

RSpec.describe ActivityController, type: :controller do
  describe "GET #index" do
    let(:application_controller) {ApplicationController.new}
    it "returns http success" do
      application_controller.class.skip_before_filter :display_release_notes
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
