# frozen_string_literal: true

RSpec.feature "Docs / Doc pages" do
  it "renders a doc index page" do
    visit "/docs/dry-operation/v1.0"

    expect(page).to have_selector "[aria-label=Breadcrumb] a", text: "dry-operation"
    expect(page).to have_selector "main header h1", text: "Introduction"
  end

  it "renders a doc page" do
    visit "/docs/dry-operation/v1.0/configuration"

    expect(page).to have_selector "[aria-label=Breadcrumb] a", text: "dry-operation"
    expect(page).to have_selector "main header h1", text: "Configuration"
  end

  it "links to all the doc's pages" do
    visit "/docs/dry-operation/v1.0"

    within "[data-testid=pages-nav]" do
      links = page.find_all("a")

      expect(links[0..2].map(&:text)).to eq [
        "Introduction",
        "Error Handling",
        "Configuration"
      ]

      expect(links[0][:href]).to eq "/docs/dry-operation/v1.0"
      expect(links[1][:href]).to eq "/docs/dry-operation/v1.0/error-handling"
    end
  end

  it "links to a doc's nested pages" do
    visit "/docs/dry-types/v1.7"

    within "[data-testid=pages-nav]", match: :first do
      parent_item = page.find("li", text: "Extensions")
      nested_nav = parent_item.find("ol")

      within nested_nav do
        nested_links = page.find_all("a")
        expect(nested_links[0..1].map(&:text)).to eq [
          "Maybe",
          "Monads"
        ]
      end
    end
  end

  it "links to other versions of the doc" do
    visit "/docs/dry-types/v1.8"

    within "[data-testid=version-select]" do
      expect(page).to have_link "v1.8", href: "/docs/dry-types/v1.8"
      expect(page).to have_link "v1.7", href: "/docs/dry-types/v1.7"
    end
  end

  it "shows a table of contents for the current page" do
    visit "/docs/dry-operation/v1.0"

    within "[data-testid=headings-toc]" do
      expect(page).to have_selector "li:nth-child(1)", text: "Introduction"
      expect(page).to have_selector "li:nth-child(2)", text: "Basic usage"
      expect(page).to have_selector "li:nth-child(3)", text: "The step method"
      expect(page).to have_selector "li:nth-child(4)", text: "The call method"
      expect(page).to have_selector "li:nth-child(5)", text: "Handling results"

      expect(page).to have_link "Basic usage", href: "#basic-usage"
    end

    heading_anchor = page.find("h2", exact_text: "Basic usage").find("a")
    expect(heading_anchor[:href]).to eq "#basic-usage"
  end

  it "shows a table of contents when headers use markdown formatting" do
    visit "/docs/dry-auto_inject/v1.1/injection-strategies"

    within "[data-testid=headings-toc]" do
      expect(page).to have_selector "li", text: "Keyword arguments (kwargs)"
    end
  end

  it "replaces //page URLs with URLs within the current doc and version" do
    visit "/docs/dry-types/v1.8"

    within ".content" do
      # In the markdown, this is linked as "//page/constraints"
      expect(page).to have_link "constrained types", href: "/docs/dry-types/v1.8/constraints"
    end
  end

  it "transforms //doc links into versionless links to a different doc" do
    visit "/docs/dry-types/v1.8/extensions/monads"

    within ".content" do
      # In the markdown, this is linked as "//doc/dry-monads"
      expect(page).to have_link "dry-monads", href: "/docs/dry-monads"
    end
  end
end
