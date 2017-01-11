require 'rails_helper'

RSpec.describe AsqMailer do
  let(:email_delivery) { FactoryGirl.create(:email_delivery) }
  let(:asq_with_email_delivery) { email_delivery.asq }

  it 'sends alert email' do
    expect { AsqMailer.send_alert_email(asq_with_email_delivery, email_delivery) }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'sends alert cleared email' do
    expect { AsqMailer.send_alert_cleared_email(asq_with_email_delivery, email_delivery) }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'sends report email' do
    expect { AsqMailer.send_report_email(asq_with_email_delivery, email_delivery) }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'sends alert email with blank results' do
    asq = asq_with_email_delivery
    asq.result = ''
    expect { AsqMailer.send_alert_email(asq, email_delivery) }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'sends report email with blank results' do
    asq = asq_with_email_delivery
    asq.result = ''
    expect { AsqMailer.send_report_email(asq, email_delivery) }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'sends attachment for report' do
    asq = asq_with_email_delivery
    mail = AsqMailer.send_report_email(asq, email_delivery)
    expect(mail.attachments.size).to eq(1)
  end

  it 'uses default subject for alert emails with no templates' do
    email_delivery.subject = ''
    mail = AsqMailer.send_alert_email(asq_with_email_delivery, email_delivery)
    expect(mail.subject).to include('Your monitor is in alert')
  end

  it 'uses default subject for report emails with no templates' do
    email_delivery.subject = ''
    mail = AsqMailer.send_report_email(asq_with_email_delivery, email_delivery)
    expect(mail.subject).to include('Your automated report is attached')
  end

  it 'uses custom subject and body for alert emails' do
    mail = AsqMailer.send_alert_email(asq_with_email_delivery, email_delivery)
    expect(mail.subject).to include(email_delivery.subject)
    expect(mail.body.encoded).to include(email_delivery.body)
  end

  it 'uses custom subject and body for report emails' do
    mail = AsqMailer.send_report_email(asq_with_email_delivery, email_delivery)
    expect(mail.subject).to include(email_delivery.subject)
    expect(mail.body.encoded).to include(email_delivery.body)
  end

  it 'ignores custom subject and body for alert clear emails' do
    mail = AsqMailer.send_alert_cleared_email(asq_with_email_delivery, email_delivery)
    expect(mail.subject).not_to include(email_delivery.subject)
    expect(mail.body.encoded).not_to include(email_delivery.body)
  end

  it 'does default body for emails nil body (alerts)' do
    email_delivery.body = nil
    mail = AsqMailer.send_alert_email(asq_with_email_delivery, email_delivery)
    expect(mail.body.encoded).to include(asq_with_email_delivery.description)
  end

  it 'does default body for emails nil body (reports)' do
    email_delivery.body = nil
    asq_with_email_delivery.query_type = 'report'
    mail = AsqMailer.send_report_email(asq_with_email_delivery, email_delivery)
    expect(mail.body.encoded).to include(asq_with_email_delivery.description)
  end
end
