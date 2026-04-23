# frozen_string_literal: true

module Site
  module OgImages
    # A single og:image to render. `output` is a path relative to public/og/
    # (e.g. "blog/2025/10/03/foo.png"); `url_path` is what gets embedded in the
    # page's <meta og:image> (e.g. "/og/blog/2025/10/03/foo.png").
    Entry = Data.define(:output, :template, :data) do
      def url_path
        "/og/#{output}"
      end

      # Plain-text summary suitable for <meta og:description>. Returns nil if
      # no description is available for this entry.
      def description
        data[:subtitle] || data[:excerpt] || data[:description]
      end

      def to_manifest_entry
        {output:, template:, data:}
      end
    end
  end
end
