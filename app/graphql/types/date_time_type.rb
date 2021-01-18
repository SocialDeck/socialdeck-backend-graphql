# frozen_string_literal: true

module Types
  class DateTimeType < Types::BaseScalar
    def self.coerce_input(value, _context)
      Date.parse(value)
    end

    def self.coerce_result(value, _context)
      value.to_date
    end
  end
end

# https://stackoverflow.com/questions/47960194/graphql-ruby-date-or-datetime-type
