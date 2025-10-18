# frozen_string_literal: true

source "https://gem.coop"

gem "hanami", "~> 2.2"
gem "hanami-assets", "~> 2.2"
gem "hanami-controller", "~> 2.2"
gem "hanami-db", "~> 2.2"
gem "hanami-router", "~> 2.2"
gem "hanami-validations", "~> 2.2"
gem "hanami-view", "~> 2.2"

gem "dry-types", "~> 1.7"
gem "dry-operation"
gem "puma"
gem "rack-rewrite"
gem "rake"
gem "sqlite3"

# Markdown content handling
gem "commonmarker"
gem "front_matter_parser"
gem "html-pipeline"
gem "amazing_print" # Required by html-pipeline
gem "debug" # Required by html-pipeline

# Views
gem "builder"

# Static site generation
gem "parklife"
gem "sitemap_generator"

group :development do
  gem "hanami-webconsole", "~> 2.2"
  gem "listen", "~> 3.0"
end

group :development, :test do
  gem "dotenv"
  gem "standard"
end

group :cli, :development do
  gem "hanami-reloader", "~> 2.2"
end

group :cli, :development, :test do
  gem "hanami-rspec", "~> 2.2"
end

group :test do
  # Database
  gem "database_cleaner-sequel"

  # Web integration
  gem "capybara"
  gem "rack-test"
end
