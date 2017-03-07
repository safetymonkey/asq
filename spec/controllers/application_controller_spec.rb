require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    def index
      render text: 'ok'
    end
  end

  describe 'debug_params' do
    it 'filters passwords' do
      get :index, params: { user: { name: Faker::Cat.name, password: Faker::Crypto.md5 } }
      expect(controller.debug_params['user']['password']).to eq('[FILTERED]')
    end
  end
end
