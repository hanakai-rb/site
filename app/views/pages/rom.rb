# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Rom < Site::View
        expose :theme, layout: true, decorate: false do
          "rom"
        end

        expose :repositories_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            class ArticleRepo < ROM::Repository
              struct_namespace MyApp::Structs

              def published
                articles.where(status: 'published').to_a
              end

              def by_author(author_id)
                articles.where(author_id: author_id).to_a
              end
            end

            # In your app
            articles = article_repo.published
            # => [#<MyApp::Structs::Article id=1 title="..." status="published">, ...]
            ```
          MARKDOWN
        end

        expose :queries_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            class Articles < ROM::Relation[:sql]
              schema :articles, infer: true

              def published
                where(status: "published")
              end

              def popular
                where { view_count > 1000 }
              end
            end

            class ArticleRepo < ROM::Repository
              def trending_by_author(author_id)
                articles
                  .published
                  .popular
                  .combine(:author)
                  .where(author_id: author_id)
                  .order(view_count: :desc)
                  .to_a
              end
            end
            ```
          MARKDOWN
        end

        expose :layers_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            class CreateArticleChangeset < ROM::Changeset::Create
              map do |tuple|
                tuple.merge(slug: slugify(tuple[:title]))
              end

              def slugify(title)
                # ...
              end
            end

            class ArticleRepo < ROM::Repository
              def create(attrs)
                articles.changeset(CreateArticleChangeset, attrs).commit
              end
            end
            ```
          MARKDOWN
        end

        expose :adapters_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            class Organizations < ROM::Relation[:http]
              # Load GitHub orgs
              schema :orgs do
                attribute :id, Types::Integer
                attribute :name, Types::String
                attribute :created_at, Types::JSON::Time
              end
            end

            # Using :http adapter with this config:
            # uri: "https://api.github.com", handlers: :json

            rom.relations[:orgs].by_name("rom-rb").one
            # => {:id=>4589832, :name=>"rom-rb", :created_at=>2013-06-01 22:03:54 UTC}
            ```
          MARKDOWN
        end
      end
    end
  end
end
