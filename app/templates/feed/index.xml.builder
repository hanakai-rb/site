# frozen_string_literal: true

xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title "Hanakai"
  xml.subtitle "Let your Ruby bloom. Hanakai is a family of Ruby tools that help you write clearer, more maintainable apps."
  xml.link "href" => "https://hanakai.org/feed.xml", "rel" => "self", "type" => "application/atom+xml"
  xml.link "href" => "https://hanakai.org/", "rel" => "alternate", "type" => "text/html"
  xml.id "#{site_url}/feed.xml"
  xml.updated (posts.first&.published_at || Time.now).iso8601

  posts.each do |post|
    xml.entry do
      xml.title post.title
      xml.link "rel" => "alternate", "href" => "#{site_url}#{post.url_path}"
      xml.id "#{site_url}#{post.url_path}"
      xml.published post.published_at.iso8601
      xml.updated post.published_at.iso8601
      xml.author do
        xml.name post.author
      end
      xml.content post.content_html, "type" => "html"
    end
  end
end
