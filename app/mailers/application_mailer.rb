# frozen_string_literal: true

# ApplicationMailer: Base mailer for application-wide mail delivery
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
