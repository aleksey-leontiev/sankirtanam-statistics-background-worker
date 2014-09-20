require "rubygems"
require "sequel"
require "mail"

# mail configuration
Mail.defaults do
  retriever_method :pop3,
    :address    => "pop.locum.ru",
    :user_name  => "sankirtanam@aleontiev.me",
    :password   => "123",
    :port       => 110,
    :enable_ssl => false

  delivery_method :smtp,
    :address    => "smtp.locum.ru",
    :user_name  => "sankirtanam@aleontiev.me",
    :password   => "123",
    :port       => 25,
    :authentication       => 'plain',
    :enable_starttls_auto => false
end

DB = Sequel.postgres('aleksey-_sanki64', :user => 'aleksey-_sanki64', :password => 'rs79EeCiT8n', :host => 'postgresql2.locum.ru')
