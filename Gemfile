source "https://rubygems.org"

ruby "~> 3.3"

gem "rails", "~> 8.0.4"
gem "pg", "~> 1.5"
gem "puma", ">= 6.0"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "propshaft"
gem "importmap-rails"

# Frontend
gem "tailwindcss-rails"
gem "turbo-rails"
gem "stimulus-rails"

# Auth / Authz
gem "devise", "~> 4.9"
gem "pundit", "~> 2.5"

# Background Jobs
# gem "sidekiq", "~> 7.3"
# gem "redis", "~> 5.0"
gem "connection_pool", "~> 2.4"

# Search
gem "pg_search", "~> 2.3"

# Rich text & uploads (built-in to Rails)
gem "image_processing", "~> 1.2"

# Utilities
gem "pagy", "~> 9.0"

group :development, :test do
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.4"
  gem "dotenv-rails", "~> 3.1"
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
end

group :test do
  gem "shoulda-matchers", "~> 7.0"
  gem "capybara", "~> 3.40"
  gem "selenium-webdriver", "~> 4.25"
  gem "pundit-matchers", "~> 3.1"
end

group :development do
  gem "letter_opener", "~> 1.10"
  gem "web-console"
  gem "rubocop-rails-omakase", require: false
end
