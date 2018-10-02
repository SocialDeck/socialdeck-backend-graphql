class ApplicationController < ActionController::Base
  include ActionController::HttpAuthentication::Token::ControllerMethods
end
