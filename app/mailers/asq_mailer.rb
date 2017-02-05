class AsqMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: 'asq-noreply@yourdomain.com'

  # send alert email
  def send_alert_email(asq, email_delivery)
    @asq = asq
    @email_delivery = email_delivery
    @subject = @email_delivery.subject.blank? ? "Your monitor is in alert: #{@asq.name}" : @email_delivery.subject
    attach_results

    # attach_logo('alert.png')
    mail to: @email_delivery.to, subject: @subject
  end

  # send alert cleared email (no custom option)
  def send_alert_cleared_email(asq, email_delivery)
    # FIXFIX remove these dumb raises and puts
    @asq = asq
    @email_delivery = email_delivery
    @subject = "Your monitor has cleared: #{@asq.name}"
    # attach_logo('cleared.png')
    mail to: @email_delivery.to, subject: @subject
  end

  # send report email
  def send_report_email(asq, email_delivery)
    @asq = asq
    @email_delivery = email_delivery
    @email_delivery.subject = "Your automated report is attached: #{@asq.name}" \
      if email_delivery.subject.blank?
    # attach_logo('report.png')
    attach_results
    mail(to: email_delivery.to, subject: @email_delivery.subject,
         body: @email_delivery.body)
  end

  private

  # attaches csv file if flagged for attachment
  def attach_results
    # if @asq.result && @asq.result.is_json? && @email_delivery.attach_results
    if @asq.result && @asq.result.is_json? && @email_delivery.attach_results
      attachments[@asq.get_processed_filename] = @asq.to_csv
    end
  end

  # attaches file name in app/assets/images to logo.png
  def attach_logo(image_name)
    path = File.join(Rails.root.to_s, '/app/assets/images/', image_name)
    attachments.inline['logo.png'] = File.read(path)
  end
end
