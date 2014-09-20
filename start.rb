$LOAD_PATH << '.'

require "configuration"
require "mail_processor"
require "report_file_processor"
require "fileutils"
require "roo"

mail_processor   = MailProcessor.new
report_processor = ReportFileProcessor.new
mails            = mail_processor.fetch_new_emails()
reports          = DB[:reports]
records          = DB[:records]
locations        = DB[:locations].all

mails.each { |mail|
  puts mail[:from] + " " + mail[:date].to_s

  mail[:attachments].each { |attacment|
    
    report_processor.process_file(attacment[:path]).each { |report|
      location  = locations.detect{|x| x[:name] == report[:meta][:location] }
      year      = report[:meta][:year]
      month     = report[:meta][:month]
      reports  << { location_id: location[:id], year: year, month: month }
      report_id = reports.order(:id).last[:id] # bad idea

      report[:data].each { |record|
        records << {
          report_id: report_id,
          name: record[:name],
          huge: record[:huge],
          big: record[:big],
          medium: record[:medium],
          small: record[:small] }
      }
    }
  }
}