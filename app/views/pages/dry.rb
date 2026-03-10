# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Dry < Site::View
        expose :theme, layout: true, decorate: false do
          "dry"
        end

        expose :validation_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            class UserContract < Dry::Validation::Contract
              params do
                required(:name).filled(:string)
                required(:age).filled(:integer)
              end

              rule(:age) { key.failure("must be greater than 18") if value < 18 }
            end
            ```
          MARKDOWN
        end

        expose :types_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            Types = Dry.Types(default: :strict)

            module Types
              Email = String.constrained(format: /@/)
              UserRole = String.enum("admin", "member", "guest")
            end

            class User < Dry::Struct
              attribute :email, Types::Email
              attribute :name, Types::String
              attribute :age, Types::Integer.constrained(gteq: 0)
              attribute :role, Types::UserRole
            end
            ```
          MARKDOWN
        end

        expose :operations_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            class CreateUser < Dry::Operation
              def call(input)
                attrs = step validate(input)
                user = step persist(attrs)
                step notify(user)
                user
              end

              private

              def validate(input)
                # Return Success(attrs) or Failure(error)
              end

              def persist(attrs)
                # Return Success(user) or Failure(error)
              end

              def notify(user)
                # Return Success(true) or Failure(error)
              end
            end
            ```
          MARKDOWN
        end

        expose :logging_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            # From simple logging
            logger = Dry.Logger(:my_app)
            logger.info("App started")

            # To structured logging and output routing
            logger = Dry.Logger(:my_app, formatter: :json) { |setup|
              setup.add_backend(stream: "logs/app.log", template: :details)
              setup.add_backend(stream: "logs/json.log", formatter: :json)
              setup.add_backend(stream: "logs/error.log", log_if: :error?)
            }
            logger.info("User signed in", user_id: 123, role: "admin")
            ```
          MARKDOWN
        end

        expose :inflections_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            inflector = Dry::Inflector.new

            # Standard transformations
            inflector.pluralize("person")         # => "people"
            inflector.singularize("categories")   # => "category"
            inflector.camelize("preferred_name")  # => "PreferredName"
            inflector.underscore("PreferredName") # => "preferred_name"

            # Configure for your domain
            inflector = Dry::Inflector.new do |inflections|
              inflections.acronym("API", "JSON", "HTTP")
            end
            ```
          MARKDOWN
        end

        expose :initializers_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            class User
              extend Dry::Initializer

              option :name, type: Types::String
              option :age, type: Types::Integer, default: proc { 18 }
              option :role, type: Types::String, default: proc { "member" }
            end

            user = User.new(name: "Alice", age: 30)
            ```
          MARKDOWN
        end

        expose :configuration_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            class CacheStore
              extend Dry::Configurable

              setting :backend, constructor: Types::String
              setting :ttl, default: 3600, constructor: Types::Integer

              setting :redis do
                setting :host, default: "localhost"
                setting :port, default: 6379
                setting :db, default: 0
              end
            end

            CacheStore.config.backend = "redis"
            CacheStore.config.redis.host = "redis.example.com"
            CacheStore.config.redis.port = 6380
            ```
          MARKDOWN
        end

        expose :systems_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            class App < Dry::System::Container
              configure do |config|
                config.component_dirs.add "lib"
              end
            end

            Deps = App.injector

            # lib/users/create.rb
            class Create < Dry::Operation
              include Deps["user_repo", "emails.welcome_email"]

              def call(attributes)
                user = user_repo.create(attributes)
                step welcome_email.delivery(user)
                Success(user)
              end
            end
            ```
          MARKDOWN
        end

        expose :cli_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            module MyApp
              module CLI
                module Commands
                  extend Dry::CLI::Registry

                  class Generate < Dry::CLI::Command
                    desc "Generate a new file"

                    argument :name, required: true, desc: "File name"
                    option :type, default: "rb", desc: "File type"

                    def call(name:, type:, **)
                      puts "Generating #{name}.#{type}..."
                    end
                  end

                  register "generate", Generate
                end
              end
            end

            Dry::CLI.new(MyApp::CLI::Commands).call
            ```
          MARKDOWN
        end
      end
    end
  end
end
