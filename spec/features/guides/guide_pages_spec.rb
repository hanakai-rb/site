# frozen_string_literal: true

RSpec.feature "Guides / Guide pages" do
  it "renders a guide index page" do
    visit "/learn/hanami/v2.2/views"

    expect(page).to have_selector "[aria-label=Breadcrumb] a", text: "Views"
    expect(page).to have_selector "main header h1", text: "Overview"
  end

  it "renders a guide page" do
    visit "/learn/hanami/v2.2/views/context"

    expect(page).to have_selector "[aria-label=Breadcrumb] a", text: "Views"
    expect(page).to have_selector "main header h1", text: "Context"
  end

  it "links to all the guide pages for an org" do
    visit "/learn/hanami/v2.2/views"

    within "[data-testid=guides-list]" do
      links = page.find_all("a")

      expect(links.map(&:text)).to include(
        "Building a web app",
        "Overview",
        "Working with dependencies",
        "Number formatting"
      )

      expect(links[0][:href]).to eq "/learn/hanami/v2.2/getting-started"
    end
  end

  it "shows a table of contents for the current page" do
    visit "/learn/hanami/v2.2/views/context"

    within "[data-testid=headings-toc]" do
      expect(page).to have_selector "li:nth-child(1)", text: "Standard context"
      expect(page).to have_selector "li:nth-child(2)", text: "Customizing the standard context"
      expect(page).to have_selector "li:nth-child(3)", text: "Decorating context attributes"
      expect(page).to have_selector "li:nth-child(4)", text: "Providing an alternative context object"
    end

    within "[data-testid=headings-toc]" do
      expect(page).to have_link "Standard context", href: "#standard-context"
    end
    heading_anchor = page.find("h2", exact_text: "Standard context").find("a")
    expect(heading_anchor[:href]).to eq "#standard-context"
  end

  it "shows a nested table of contents when there are headings of varying levels" do
    visit "/learn/hanami/v2.2/getting-started"

    within "[data-testid=headings-toc]", match: :first do
      parent_item = page.find("li", text: "Creating a Hanami app")
      nested_nav = parent_item.find("ol")

      within nested_nav do
        nested_links = page.find_all("a")
        expect(nested_links[0..1].map(&:text)).to eq [
          "Prerequisites",
          "Installing the gem"
        ]
      end
    end
  end

  it "links to the other guides, in correct order" do
    visit "/learn/hanami/v2.2/views"

    within "[data-testid=guides-list]" do
      all_guide_names = page.find_all("li a").map(&:text)

      expect(all_guide_names[0..4]).to eq [
        "Overview",
        "Building a web app",
        "Building an API",
        "Commands",
        "New"
      ]
    end
  end

  it "replaces //page URLs with URLs within the current guide and version" do
    visit "/learn/hanami/v2.2/actions"

    within ".content" do
      # In the markdown, this is linked as "//page/parameters"
      expect(page).to have_link "parameters", href: "/learn/hanami/v2.2/actions/parameters"
    end
  end

  it "transforms //guide links into links to a different guide within the current version" do
    visit "/learn/hanami/v2.2/getting-started/building-a-web-app"

    within ".content" do
      # In the markdown, this is linked as "//guide/actions"
      expect(page).to have_link "Actions guide", href: "/learn/hanami/v2.2/actions"
    end
  end

  it "renders next nav link to next page in the same guide" do
    visit "/learn/hanami/v2.2/getting-started"
    expect(page).to have_selector '[aria-label="Go to next guide"]', text: "Building a web app"
  end

  it "renders next link to next nav guide when no more pages in current" do
    visit "/learn/hanami/v2.2/getting-started/building-an-api"
    expect(page).to have_selector '[aria-label="Go to next guide"]', text: "Command line"
  end

  it "does not render next nav link on the last page of the guides" do
    visit "/learn/hanami/v2.2/faq"
    expect(page).not_to have_selector '[aria-label="Go to next guide"]'
  end

  it "renders previous nav link to previous page in the same guide" do
    visit "/learn/hanami/v2.2/getting-started/building-an-api"
    expect(page).to have_selector '[aria-label="Go to previous guide"]', text: "Building a web app"
  end

  it "renders previous nav link to last page of a previous guide" do
    visit "/learn/hanami/v2.2/command-line"
    expect(page).to have_selector '[aria-label="Go to previous guide"]', text: "Building an API"
  end

  it "does not render previous nav link on the first page of the guides" do
    visit "/learn/hanami/v2.2/getting-started"
    expect(page).not_to have_selector '[aria-label="Go to previous guide"]'
  end

  it "renders nav links pointing to the same version of guides" do
    visit "/learn/hanami/v2.0/app/settings"
    expect(page).to have_link
    next_link = page.find('[aria-label="Go to next guide"]')
    expect(next_link[:href]).to eq("/learn/hanami/v2.0/app/autoloading")

    previous_link = page.find('[aria-label="Go to previous guide"]')
    expect(previous_link[:href]).to eq("/learn/hanami/v2.0/app/providers")
  end

  it "links to the same guide page in the version selector when switching versions" do
    visit "/learn/hanami/v2.2/actions/parameters"

    within "[aria-label=Breadcrumb]" do
      find("button", text: "v2.2").click
      expect(find("a", text: "v2.0")[:href]).to eq("/learn/hanami/v2.0/actions/parameters")
    end
  end

  it "links to the guide index in version selector when guide exists but page doesn't" do
    # The rendering-views page exists in v2.2 but not in v2.0
    visit "/learn/hanami/v2.2/actions/rendering-views"

    within "[aria-label=Breadcrumb]" do
      find("button", text: "v2.2").click
      expect(find("a", text: "v2.0")[:href]).to eq("/learn/hanami/v2.0/actions")
    end
  end

  it "links to the first guide page in version selector when current guide doesn't exist in that version" do
    # The database guide exists in v2.2 but not in v2.0
    visit "/learn/hanami/v2.2/database"

    within "[aria-label=Breadcrumb]" do
      find("button", text: "v2.2").click
      expect(find("a", text: "v2.0")[:href]).to eq("/learn/hanami/v2.0/getting-started")
    end
  end
end
