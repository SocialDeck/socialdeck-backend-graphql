DateTimeType = GraphQL::ScalarType.define do
  name 'DateTime'

  coerce_input ->(value, _ctx) { Time.zone.parse(value) }
  coerce_result ->(value, _ctx) { value.utc.iso8601 }
end

MyType = ::GraphQL::ObjectType.define do
  name 'MyType'
  field :when, type: !DateTimeType
end

#https://stackoverflow.com/questions/47960194/graphql-ruby-date-or-datetime-type