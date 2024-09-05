# frozen_string_literal: true

module Decidim
  module HomepageProposals
    class TagsCell < Decidim::TagsCell
      def tag_item(name, title)
        content_tag :span, title:, class: "tag" do
          sr_title = content_tag(
            :span,
            title,
            class: "sr-only"
          )
          display_title = content_tag(
            :span,
            name,
            "aria-hidden": true
          )

          icon("price-tag-3-line") + sr_title + display_title
        end
      end
    end
  end
end
