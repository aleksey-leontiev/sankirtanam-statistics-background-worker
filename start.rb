$LOAD_PATH << '.'

require "configuration"
require "mail_processor"
require "report_file_processor"
require "fileutils"
require "roo"

mail_processor   = MailProcessor.new
report_processor = ReportFileProcessor.new 
mails            = mail_processor.fetch_new_emails()
table            = DB[:reports]

mails.each { |mail|
  puts mail[:from] + " " + mail[:date].to_s
  mail[:attachments].each { |attacment|

    table << { location_id:1, year:2014, month:1  }

    #puts attacment[:path]
    #puts "----------"
    report_processor.process_file(attacment[:path]).each { |report|
      puts "------"
      #puts report
      report[:data].each { |record| 
      	puts record[:name]
      }
    }
  }
}



#Mail.all.each { |mail|
#  puts "123"
#}

#DB.fetch("SELECT name FROM users") do |row|
#  p row[:name]
#end
