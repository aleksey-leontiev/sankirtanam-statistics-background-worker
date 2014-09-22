# mail processor
class MailProcessor
  
  # fetches new mail
  def fetch_emails_after(datetime)
    result = []

    a = Mail.all.select do |mail|
      mail.date > datetime
    end

    a.each do |mail|
      result << process_email(mail)
    end

    result
  end

  def send_email(message)
    Mail.deliver do
      from     'sankirtanam@aleontiev.me'
      to       'aleksey.leontiev@icloud.com'
      subject  'Sankirtanam'
      
      html_part do
        content_type 'text/html; charset=UTF-8'
        body message
      end

    end
  end

  private

  def process_email(mail)
    result = {}
    result[:from] = mail.from[0]
    result[:date] = mail.date
    result[:attachments] = []

    mail.attachments.each { |attachment|
      folder = File.join("files", result[:from], result[:date].strftime("%F"))
      path   = File.join(folder, attachment.filename)
      FileUtils::mkdir_p File.join(folder)
      File.open(path, "w+b", 0644) { |f| f.write attachment.body.decoded }

      result[:attachments] << {
        path: path,
        filename: attachment.filename
      }
    }

    result
  end
end