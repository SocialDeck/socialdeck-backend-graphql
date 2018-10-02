class ApplicationController < ActionController::Base
  include ActionController::HttpAuthentication::Token::ControllerMethods
  protect_from_forgery with: :exception
end
