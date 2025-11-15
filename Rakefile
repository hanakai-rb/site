# frozen_string_literal: true

require "hanami/rake_tasks"
require "rubocop/rake_task"
require "sitemap_generator/tasks"

# Load custom rake tasks
Rake.add_rakelib "lib/tasks"

RuboCop::RakeTask.new

desc "Run code quality checks"
task lint: %i[rubocop]

Rake::Task["default"].clear
task default: %i[lint spec]

namespace :tailwind do
  desc "Compile your Tailwind CSS"
  task :compile do
    system(
      "npx",
      "@tailwindcss/cli",
      "--input", "app/assets/css/tailwind.css",
      "--output", "app/assets/builds/tailwind.css"
    )
  end

  desc "Watch and compile your Tailwind CSS on file changes"
  task :watch do
    system(
      "npx",
      "@tailwindcss/cli",
      "--input", "app/assets/css/tailwind.css",
      "--output", "app/assets/builds/tailwind.css",
      "--watch"
    )
  end
end
