# frozen_string_literal: true

class Shortlink < ApplicationRecord
  has_secure_token
end
