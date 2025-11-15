# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite, :search) do
    next if File.exist?("public/pagefind/pagefind-entry.json")

    system("bin/rake search:build_index") || raise("Failed to build search index")
  end
end
