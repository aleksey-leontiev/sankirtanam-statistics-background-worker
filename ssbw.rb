# encoding:utf-8

require "mail"
require "roo"
require "json"
require "fileutils"

$LOAD_PATH << '.'

require "worksheet_processor"

# mail configuration
Mail.defaults do
  retriever_method :pop3,
    :address    => "pop.locum.ru",
    :user_name  => "sankirtanam@aleontiev.me",
    :password   => "123",
    :port       => 110,
    :enable_ssl => false
end


$processed = File.readlines("processed.db")
$result = []

Mail.all.each { |mail|
  mail.attachments.each { |attachment|
    id = mail.message_id + attachment.filename
    alreadyProcessed = $processed.any? { |s| id == s.strip }
    if alreadyProcessed
      next
    else
      puts mail.from[0] + " " + attachment.filename
    
      from = mail.from[0]
      date = mail.date.strftime("%F")
      name = attachment.filename
      path = File.join("files", from, date, name)
      FileUtils::mkdir_p File.join("files", from, date)
      File.open(path, "w+b", 0644) { |f| f.write attachment.body.decoded }
      
      begin
        $result << { :file_name => path, :data => WorksheetProcessor.process_file(path) }
      rescue Exception => e
        $result << { :file_name => path, :error => e }
      end

      $processed << id
    end
  }
}

File.open("processed.db", "w") { |f| f.puts($processed) }

puts $result.to_json