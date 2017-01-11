require 'rails_helper'

RSpec.describe Asq, type: :model do
  let(:asq_no_file_options) { FactoryGirl.create(:asq) }
  before (:each) do
    Delayed::Worker.delay_jobs = false
  end
  describe '.status' do

    describe 'accurately descirbes its current state' do
      context 'when asq.status == alert_new' do
        asq = FactoryGirl.build(:asq, status: 'alert_new')
        it 'is in alert' do
          expect(asq.in_alert?).to be true
        end
        it 'is not formerly in alert' do
          expect(asq.formerly_in_alert?).to be false
        end
      end

      context 'when .status == alert_still' do
        asq = FactoryGirl.build(:asq, status: 'alert_still')
        it 'is in alert' do
          expect(asq.in_alert?).to be true
        end
        it 'is formerly in alert' do
          expect(asq.formerly_in_alert?).to be true
        end
      end

      context 'when .status = clear_new' do
        asq = FactoryGirl.build(:asq, status: 'clear_new')
        it 'is not in alert' do
          expect(asq.in_alert?).to be false
        end
        it 'is formerly in alert' do
          expect(asq.formerly_in_alert?).to be true
        end
      end

      context 'when .status = clear_still' do
        asq = FactoryGirl.build(:asq)
        it 'is not in alert' do
          expect(asq.in_alert?).to be false
        end
        it 'is not formerly_in_alert' do
          expect(asq.formerly_in_alert?).to be false
        end
        it 'is not in operational_error' do
          expect(asq.operational_error?).to be false
        end
      end
    end

    describe 'accurately sets current status' do
      context 'alerting from clear_still' do
        asq_clear_still = FactoryGirl.build(:asq, status: 'clear_still')
        it 'sets status to alert new with .alert' do
          asq_clear_still.alert('default message')
          expect(asq_clear_still.status).to eq('alert_new')
        end
        it 'updates status to alert_still when .alert called again' do
          asq_clear_still.alert('default message')
          expect(asq_clear_still.status).to eq('alert_still')
        end
      end

      context 'when clearing from alert_still' do
        asq_in_alert = FactoryGirl.build(:asq, status: 'alert_still')
        it '.clear sets status to clear_new' do
          asq_in_alert.clear
          expect(asq_in_alert.status).to eq('clear_new')
        end
        it 'calling .clear again sets status to clear_still' do
          asq_in_alert.clear
          expect(asq_in_alert.status).to eq('clear_still')
        end
      end

      context 'when setting to operational_error' do
        asq = FactoryGirl.build(:asq, status: 'clear_still')
        it 'calling operational_error sets state = operational_error' do
          asq.operational_error
          expect(asq.status).to eq('operational_error')
        end

        it 'asq is not in_alert' do
          expect(asq.in_alert?).to be false
        end
      end
    end
  end
  it 'passes in the max of created, modified and last run
    to get_scheduled_date' do
    modified_on = 1.day.ago
    asq_params = { modified_on: modified_on, created_on: 5.days.ago,
                   last_run: 3.days.ago }
    asq = FactoryGirl.build(:asq, asq_params)
    schedule = FactoryGirl.build(:weekly_schedule)
    allow(asq).to receive(:schedules).and_return([schedule])
    expect(schedule).to receive(:get_scheduled_date)
                            .with(modified_on).and_return(modified_on)
    asq.needs_refresh?
  end

  it 'calls finish_refresh on alert' do
    expect(asq_no_file_options).to receive(:finish_refresh)
    asq_no_file_options.alert('default message')
  end

  it '.finish_refresh does nothing unless refresh_in_progress' do
    expect(asq_no_file_options).not_to receive(:save)
    asq_no_file_options.finish_refresh
  end

  it 'get_processed_filename returns asq.name + csv when
    no file options present' do
    expect(asq_no_file_options.get_processed_filename)
      .to eq(asq_no_file_options.name + '.csv')
  end

  context 'On refresh' do
    it 'calls Refresher.refresh' do
      expect(Refresher).to receive(:refresh).with(asq_no_file_options.id, true)
      asq_no_file_options.refresh(true)
    end
  end

  describe '.log' do
    context 'when Asq goes into operational_error' do
      it '.log captures the error message' do
        asq = FactoryGirl.create(:asq)
        expect(asq).to receive(:log)
        asq.operational_error
      end
    end
  end
end
