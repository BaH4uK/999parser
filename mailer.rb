require 'action_mailer'

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
   :address        => "smtp.gmail.com",
   :port           => 587,
   :domain         => "domain.com.ar",
   :authentication => :plain,
   :user_name      => "",
   :password       => "",
   :enable_starttls_auto => true
  }
ActionMailer::Base.view_paths= File.dirname(__FILE__)

class Mailer < ActionMailer::Base

  def offer(from, to, subject, details)
    @details = details
    mail(:to => to.values, :from => from, :subject => subject) do |format|
      format.html
    end
  end
end
