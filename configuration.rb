
# mail configuration
Mail.defaults do
  retriever_method :pop3,
    :address    => "?",
    :user_name  => "?",
    :password   => "?",
    :port       => 110,
    :enable_ssl => false

  delivery_method :smtp,
    :address    => "?",
    :user_name  => "?",
    :password   => "?",
    :port       => 25,
    :authentication       => 'plain',
    :enable_starttls_auto => false
end

DB = Sequel.postgres('db', :user => '?', :password => '?', :host => '?')