# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Hanami < Site::View
        expose :theme, layout: true, decorate: false do
          "hanami"
        end

        expose :database_code, decorate: false do
          <<~'MARKDOWN'
            ```ruby
            # app/relations/articles.rb
            class Articles < Hanami::DB::Relation
              schema :articles, infer: true

              def published
                where(published: true).order { created_at.desc }
              end
            end
            ```

            ```ruby
            # app/repos/article_repo.rb
            class ArticleRepo < MyApp::Repo
              def update(id, attributes)
                articles.by_pk(id).changeset(:update, attributes).commit
              end

              def find(id)
                articles.published.by_pk(id).one!
              end

              def latest
                articles.published.limit(10).to_a
              end
            end
            ```

            ```ruby
            # app/structs/article.rb
            class Article < MyApp::DB::Struct
              def summary
                "#{title} (#{author_name}, #{published_at.year})"
              end
            end
            ```
          MARKDOWN
        end

        expose :business_logic_code, decorate: false do
          <<~MARKDOWN
            ```ruby
            # app/articles/update.rb
            class Update < MyApp::Operation
              include Deps["repos.article_repo"]

              def call(article_id, attributes)
                validation = step validate(attributes)
                article = article_repo.update(article_id, validation.to_h)
                Success(article)
              end

              private

              def validate(attributes)
                # returns a Success or Failure
              end
            end
            ```
          MARKDOWN
        end

        expose :routing_code, decorate: false do
          <<~MARKDOWN
            ```ruby
            # config/routes.rb
            module MyApp
              class Routes < Hanami::Routes
                root to: "home.show"

                resources "articles"
              end
            end
            ```
          MARKDOWN
        end

        expose :actions_code, decorate: false do
          <<~MARKDOWN
            ```ruby
            # app/actions/articles/update.rb
            class Update < MyApp::Action
              include Deps[update_article: "articles.update"]

              def handle(request, response)
                result = update_article.call(
                  request.params[:id],
                  request.params[:article]
                )

                case result
                in Success(article)
                  response.redirect_to routes.path(:article, article.id)
                in Failure(validation)
                  response.render view, validation:
                end
              end
            end
            ```
          MARKDOWN
        end

        expose :views_code, decorate: false do
          <<~MARKDOWN
            ```ruby
            # app/views/articles/show.rb
            class Show < MyApp::View
              include Deps["repos.article_repo"]

              expose :article do |id:|
                article_repo.get(id)
              end
            end
            ```

            ```erb
            <%# app/templates/articles/show.html.erb %>
            <h1><%= article.title %></h1>
            <%= article.body_html %>
            ```
          MARKDOWN
        end
      end
    end
  end
end
