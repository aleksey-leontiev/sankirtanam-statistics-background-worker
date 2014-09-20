class MailProcessor
  def fetch_new_emails()
    result = []

    Mail.all.each { |mail|
      result << process_email(mail)
    }

    result
  end

  def send_email()
    Mail.deliver do
      from     'sankirtanam@aleontiev.me'
      to       'aleksey.leontiev@icloud.com'
      subject  'Sankirtanam'
      body     'Test'
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
        path: path
      }
	  }

    result
  end
end