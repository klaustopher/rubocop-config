class ApplicationMailer < ActionMailer::Base
  default from: "Tracker <notifications@tracker.example>"
  layout "mailer"
end
