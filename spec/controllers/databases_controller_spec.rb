require 'rails_helper'

RSpec.describe DatabasesController, type: :controller do
  fixtures :users

  before(:example) do
    sign_in(User.find_by_login('aadmin'))
  end

  describe 'GET #new' do
    it 'populates @db_types' do
      mock_response = 'stub'
      allow(controller)
        .to receive(:available_db_types)
        .and_return(mock_response)
      get :new
      expect(assigns(:db_types)).to eq(mock_response)
    end
  end

  describe 'GET #edit' do
    let(:db) { FactoryGirl.create(:database) }
    it 'populates @db_types' do
      mock_response = 'stub'
      allow(controller)
        .to receive(:available_db_types)
        .and_return(mock_response)
      get :edit, params: { id: db.id }
      expect(assigns(:db_types)).to eq(mock_response)
    end
  end

  describe 'GET #edit' do
  end

  describe 'available_db_types' do
    describe 'when all dbs enabled' do
      it 'return expected db types' do
        expected_response = [
          %w(MySQL mysql), %w(PostgreSQL postgres), %w(Oracle oracle)
        ]
        feature_response('oracle_db', true)
        feature_response('mysql_db', true)
        feature_response('postgres_db', true)
        expect(controller.available_db_types).to eq(expected_response)
      end
    end
    describe 'when some dbs enabled' do
      it 'return expected db types' do
        expected_response = [
          %w(MySQL mysql)
        ]
        feature_response('oracle_db', false)
        feature_response('mysql_db', true)
        feature_response('postgres_db', false)
        expect(controller.available_db_types).to eq(expected_response)
      end
    end
    describe 'when no dbs enabled' do
      it 'return expected db types' do
        expected_response = [
          ['No DB types available', '']
        ]
        feature_response('oracle_db', false)
        feature_response('mysql_db', false)
        feature_response('postgres_db', false)
        expect(controller.available_db_types).to eq(expected_response)
      end
    end
  end
end

def feature_response(feature, response)
  allow(Rails.configuration.feature_settings)
    .to receive(:[])
    .with(feature)
    .and_return(response)
end
