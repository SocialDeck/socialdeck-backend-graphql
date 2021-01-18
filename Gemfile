# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'pg'
gem 'rails'
# Use Puma as the app server
gem 'bcrypt'
gem 'faker'
gem 'figaro'
gem 'jwt'
gem 'pg_search'
gem 'puma'
gem 'sendgrid-ruby'
gem 'simple_command'
gem 'warden'

gem 'csv'
gem 'rack-cors', require: 'rack/cors'
gem 'rqrcode'
gem 'telephone_number'
gem 'valid_email2'

# gem to facilate GraphQL
gem 'graphql'
gem 'search_object'
gem 'search_object_graphql'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'graphiql-rails'
  gem 'rubocop'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
