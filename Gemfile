# frozen_string_literal: true

source "https://gem.coop"

ruby "3.4.7"

gem "hanami", "~> 3.0.0"
gem "hanami-action", "~> 3.0.0"
gem "hanami-assets", "~> 3.0.0"
gem "hanami-db", "~> 3.0.0"
gem "hanami-router", "~> 3.0.0"
gem "hanami-view", "~> 3.0.0"

gem "dry-types", "~> 1.7"
gem "dry-operation"
gem "dry-validation"
gem "puma"
gem "rack-rewrite"
gem "rake"
gem "sqlite3"

# Markdown content handling
gem "commonmarker"
gem "fastimage"
gem "front_matter_parser"
gem "html-pipeline"
gem "amazing_print" # Required by html-pipeline
gem "debug" # Required by html-pipeline

# Views
gem "builder"

# Static site generation
gem "parklife", github: "benpickles/parklife", ref: "fe7f3d3" # for benpickles/parklife#136
gem "sitemap_generator"

group :development do
  gem "hanami-webconsole", "~> 3.0.0"
  gem "listen", "~> 3.0"
  gem "herb", "~> 0.9"
end

group :development, :test do
  gem "dotenv"
  gem "rouge"
  gem "standard"
end

group :cli, :development do
  gem "hanami-reloader", "~> 3.0.0"
end

group :cli, :development, :test do
  gem "hanami-rspec", "~> 3.0.0"
end

group :test do
  # Database
  gem "database_cleaner-sequel"

  # Web integration
  gem "capybara"
  gem "rack-test"
end
