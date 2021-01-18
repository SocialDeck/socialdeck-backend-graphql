# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActionController::HttpAuthentication::Token::ControllerMethods
end
