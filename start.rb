$LOAD_PATH << '.'

require "rubygems"
require "sequel"
require "mail"
require "fileutils"
require "roo"

require "configuration"
require "mail_processor"
require "report_file_processor"

$mail_processor     = MailProcessor.new
$report_processor   = ReportFileProcessor.new
$reports            = DB[:reports]
$records            = DB[:records]
$locations          = DB[:locations].all

def start()
  lastsync = DateTime.new(1900, 1, 1)
  now      = DateTime.now

  # define last sync date
  begin
    line     = File.open("lastsync", 'r') { |file| file.read }
    lastsync = DateTime.parse(line)
  rescue Exception => e
    puts "Unable to determine last sync date: #{e.message}"
  end

  # fetch and process incoming emails
  begin
    # fetch and group by sender
    mails  = $mail_processor.fetch_emails_after(lastsync)
    groups = mails.inject({}) {|memo, value| (memo[value[:from]] ||= []) << value; memo}

    # process each 
    groups.keys.each do |key|
      process_group_of_emails(key, groups[key])
    end

    # save last sync date
    File.open("lastsync", 'w') { |file| file.write(now) }
  rescue Exception => e
    puts "#{e.message}"
    send_report("General error: #{e.message}")
  end
end 

def process_group_of_emails(email, group)
  puts "#{email}:"

  states = [] # { succeed, filename, location, message }
  report = ""

  group.each do |mail|
    process_email(mail, states)
  end

  report += "<table border=1>"
  states.each do |state|
    report += "<tr><td>#{state[:filename]}</td><td>#{state[:location]}</td><td>#{state[:succeed]}: #{state[:message]}</td></tr>"
  end
  report += "</table>"
  
  send_report(report)
end

def process_email(mail, states)
  puts "  #{mail[:date]}:"
  mail[:attachments].each do |attacment|
    process_attachment(attacment, states)
  end
end

def process_attachment(attacment, states)
  puts "    #{attacment[:path]}"
  begin
    reports = $report_processor.process_file(attacment[:path])
  rescue Exception => e
    states << {filename: attacment[:path], succeed: false, message: e.message}
    return
  end

  reports.each { |report|
    process_report(report, attacment[:filename], states)
  }
end

def process_report(report, filename, states)
  state   = {filename:filename}
  states << state

  puts "      #{report[:meta][:location]} #{report[:meta][:month]}/#{report[:meta][:year]}"
  location  = $locations.detect{|x| x[:name] == report[:meta][:location] }
  year      = report[:meta][:year]
  month     = report[:meta][:month]

  #state[:date] = "#{month}/#{year}"

  if !is_number?(month) || !is_number?(year) then
    state[:succeed] = false
    state[:message] = "date is not correct"
    return
  end

  if location == nil then
    state[:succeed] = false
    state[:message] = "location is not found"
    return
  end

  $reports  << { location_id: location[:id], year: year, month: month }
  report_id = $reports.order(:id).last[:id] # bad idea

  state[:location] = report[:meta][:location]

  report[:data].each { |record|
    $records << {
      report_id: report_id,
      name:   record[:name],
      huge:   record[:huge],
      big:    record[:big],
      medium: record[:medium],
      small:  record[:small] }
  }

  state[:succeed] = true
end

def send_report(message)
  $mail_processor.send_email(message)
end

def is_number?(object)
  true if Float(object) rescue false
end

start()