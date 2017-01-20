require 'rails_helper'
RSpec.describe AsqsController, type: :controller do
  let(:asqs) do
    [FactoryGirl.create(:asq,
                        name: 'three',
                        query_type: 0,
                        status: 'alert_still',
                        disabled: false,
                        last_run: Time.now),
     FactoryGirl.create(:asq,
                        name: 'five',
                        query_type: 0,
                        status: 'clear_new',
                        disabled: true,
                        last_run: Time.now - (60 * 10)),
     FactoryGirl.create(:asq,
                        name: 'seven',
                        query_type: 1,
                        disabled: true,
                        last_run: Time.now - (60 * 12)),
     FactoryGirl.create(:asq,
                        name: 'six',
                        query_type: 0,
                        status: 'clear_still',
                        disabled: true,
                        last_run: Time.now - (60 * 14)),
     FactoryGirl.create(:asq,
                        name: 'four',
                        query_type: 1,
                        disabled: false,
                        last_run: Time.now - (60 * 16)),
     FactoryGirl.create(:asq,
                        name: 'two',
                        query_type: 0,
                        status: 'alert_new',
                        disabled: false,
                        last_run: Time.now - 20),
     FactoryGirl.create(:asq,
                        name: 'one',
                        query_type: 0,
                        status: 'operational_error',
                        disabled: false,
                        last_run: Time.now - 60)]
  end

  describe '::index' do
    fixtures :asq_statuses
    it 'sorts asqs in proper order' do
      asqs

      get :index
      # expect(assigns(:asqs).length).to eq(7)
      expect(assigns(:asqs)[0].name).to eq('one')
      expect(assigns(:asqs)[1].name).to eq('two')
      expect(assigns(:asqs)[2].name).to eq('three')
      expect(assigns(:asqs)[3].name).to eq('four')
      expect(assigns(:asqs)[4].name).to eq('five')
      expect(assigns(:asqs)[5].name).to eq('six')
      expect(assigns(:asqs).last.name).to eq('seven')
    end

    it 'sorts tagged asqs in proper order' do
      asqs.each do |a|
        a.tag_list.add('bingo')
        a.save
      end

      get :index, params: { tag: 'bingo' }
      # expect(assigns(:asqs).length).to eq(7)
      expect(assigns(:asqs)[0].name).to eq('one')
      expect(assigns(:asqs)[1].name).to eq('two')
      expect(assigns(:asqs)[2].name).to eq('three')
      expect(assigns(:asqs)[3].name).to eq('four')
      expect(assigns(:asqs)[4].name).to eq('five')
      expect(assigns(:asqs)[5].name).to eq('six')
      expect(assigns(:asqs).last.name).to eq('seven')
    end

    context '@up_to_date' do
      it 'returns true if all asq are up to date' do
        asqs
        get :index
        expect(assigns(:up_to_date)).to be true
      end

      it 'returns false if one of the asqs has not been run in 20 min' do
        FactoryGirl.create(:asq,
                           name: 'one',
                           query_type: 0,
                           status: 'operational_error',
                           disabled: false,
                           last_run: Time.now - 86_400)
        get :index
        expect(assigns(:up_to_date)).to be false
      end
    end
  end

  describe '.activity_rows' do
    # This test has to run first because the data that gets created from
    # previous runs gets deleted but does not reset the primary key in the
    # database.
    it 'paginates correctly with last_id' do
      a = asqs[0]
      (1..100).to_a.each do |num|
        a.log('warn', "activity #{num}")
      end
      get :activity_rows, params: { id: a.id, last_id: 91 }
      expect(assigns(:activities)[0].detail).to eq('activity 90')
      expect(assigns(:activities).last.detail).to eq('activity 16')
    end
    it 'response 200' do
      a = asqs[0]
      (1..10).to_a.each do |num|
        a.log('warn', "activity #{num}")
      end
      get :activity_rows, params: { id: a.id }
      expect(response.status).to eq(200)
    end

    it 'generates correct activity count' do
      a = asqs[0]
      (1..10).to_a.each do |num|
        a.log('warn', "activity #{num}")
      end
      get :activity_rows, params: { id: a.id }
      expect(assigns(:activities).length).to eq(10)
    end

    it 'orders activity correctly' do
      a = asqs[0]
      (1..10).to_a.each do |num|
        a.log('warn', "activity #{num}")
      end
      get :activity_rows, params: { id: a.id }
      expect(assigns(:activities)[0].detail).to eq('activity 10')
      expect(assigns(:activities).last.detail).to eq('activity 1')
    end

    it 'paginates at 75' do
      a = asqs[0]
      (1..100).to_a.each do |num|
        a.log('warn', "activity #{num}")
      end
      get :activity_rows, params: { id: a.id }
      expect(assigns(:activities)[0].detail).to eq('activity 100')
      expect(assigns(:activities).last.detail).to eq('activity 26')
    end

    it 'returns 404 when no items remain' do
      a = asqs[0]
      (1..10).to_a.each do |num|
        a.log('warn', "activity #{num}")
      end
      expect { get :activity_rows, params: { id: a.id, last_id: a.activities.first.id } }
        .to raise_error(ActionController::RoutingError)
    end

    # We're defining the Asq in each test rather than using a let statement,
    # because that would require us to save the asq after modfying it,
    # which would actually require *more* lines of code in the test, for
    # minimal gain.
    describe 'Asq status for Nagios' do
      it 'returns clear_new in JSON format' do
        asq = FactoryGirl.create(:asq, status: 'clear_new')
        get :show, params: { format: :json, id: asq.id }
        parsed_json = JSON.parse(response.body)
        expect(parsed_json['status']).to eq('clear_new')
      end

      it 'returns clear_still in JSON format' do
        asq = FactoryGirl.create(:asq, status: 'clear_still')
        get :show, params: { format: :json, id: asq.id }
        parsed_json = JSON.parse(response.body)
        expect(parsed_json['status']).to eq('clear_still')
      end

      it 'returns alert_new in JSON format' do
        asq = FactoryGirl.create(:asq, status: 'alert_new')
        get :show, params: { format: :json, id: asq.id }
        parsed_json = JSON.parse(response.body)
        expect(parsed_json['status']).to eq('alert_new')
      end

      it 'returns alert_still in JSON format' do
        asq = FactoryGirl.create(:asq, status: 'alert_still')
        get :show, params: { format: :json, id: asq.id }
        parsed_json = JSON.parse(response.body)
        expect(parsed_json['status']).to eq('alert_still')
      end

      it 'returns operational_error in JSON format' do
        asq = FactoryGirl.create(:asq, status: 'operational_error')
        get :show, params: { format: :json, id: asq.id }
        parsed_json = JSON.parse(response.body)
        expect(parsed_json['status']).to eq('operational_error')
      end
    end
  end
end
