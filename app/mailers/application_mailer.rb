# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'info@socialdeck.xyz'
  layout 'mailer'
end
