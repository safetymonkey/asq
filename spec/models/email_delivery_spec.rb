require 'rails_helper'

RSpec.describe EmailDelivery, type: :model do
  let(:email_delivery) { FactoryBot.create(:email_delivery) }
  let(:asq) { delivery.asq }

  before :each do
    email_delivery
    @mock_mail = double
    allow(@mock_mail).to receive(:deliver_now)
  end

  it 'calls AsqMailer\'s report method when parent query_type is report' do
    expect(AsqMailer).to receive(:send_report_email).and_return @mock_mail
    email_delivery.deliver
  end

  it 'calls AsqMailer\'s alarm method when parent query_type is monitor
      and it is in alarm' do
    email_delivery.asq.query_type = 'monitor'
    email_delivery.asq.status = 'alert_new'

    expect(AsqMailer).to receive(:send_alert_email).and_return @mock_mail
    email_delivery.deliver
  end

  it 'calls AsqMailer\'s all_clear method when parent query_type is monitor
      and it is not in alarm' do
    email_delivery.asq.query_type = 'monitor'
    email_delivery.asq.status = 'clear_new'
    email_delivery.asq.deliver_on_all_clear = true

    expect(AsqMailer).to receive(:send_alert_cleared_email).and_return @mock_mail
    email_delivery.deliver
  end

  it 'only calls all_clear if the Asq has that option enabled' do
    email_delivery.asq.query_type = 'monitor'
    email_delivery.asq.status = 'clear_new'
    email_delivery.asq.deliver_on_all_clear = false
    expect(AsqMailer).not_to receive(:send_alert_cleared_email)
    email_delivery.deliver
  end

  it 'deletes after save if all values are empty' do
    empty_email = EmailDelivery.new
    expect(empty_email).to receive(:destroy).and_call_original
    empty_email.save
  end

  describe '.should_archive_file?' do
    context 'while @should_archive is true' do
      it 'returns true' do
        email_delivery.instance_variable_set(:@should_archive, true)
        expect(email_delivery.should_archive_file?).to be_truthy
      end
    end
    context 'while @should_archive_file is false' do
      it 'returns false' do
        email_delivery.instance_variable_set(:@should_archive, false)
        expect(email_delivery.should_archive_file?).to be_falsy
      end
    end
    context 'while @should_archive_file is not present' do
      it 'returns false' do
        expect(email_delivery.should_archive_file?).to be_falsy
      end
    end
  end
end
