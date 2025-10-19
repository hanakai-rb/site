# frozen_string_literal: true

# These specs are very basic, just to ensure the blog pages render correctly. We can apply more
# directed tests later on, when we consider a fixtures-based approach to testing the site.
RSpec.feature "Blog" do
  it "displays a paginated list of the latest posts" do
    visit "/blog"

    posts = page.find_all("[data-testid=blog-post]")
    expect(posts.length).to eq 10

    post_titles_1 = posts.map { |it| it.find("h2").text }

    click_link "Next ›"

    posts = page.find_all("[data-testid=blog-post]")
    expect(posts.length).to eq 10

    post_titles_2 = posts.map { |it| it.find("h2").text }

    expect((post_titles_1 + post_titles_2).uniq.length).to eq 20

    click_link "‹ Previous"

    posts = page.find_all("[data-testid=blog-post]")
    post_titles_3 = posts.map { |it| it.find("h2").text }
    expect(post_titles_3).to eq post_titles_1
  end

  it "displays individual posts" do
    visit "/blog"

    first_post = page.find("[data-testid=blog-post]", match: :first)
    first_post.find("h2 a").click

    expect(page).to have_selector ".content"
  end
end
