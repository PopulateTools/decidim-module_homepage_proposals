# frozen_string_literal: true

module Decidim
  module HomepageProposals
    module ContentBlocks
      class ProposalsSliderSettingsFormCell < Decidim::ViewModel
        include ActionView::Helpers::FormOptionsHelper

        alias form model

        def content_block
          options[:content_block]
        end

        def options_for_proposals_components
          options = proposals_components.map do |proposal_component|
            ["#{translated_attribute(proposal_component.name)} (#{translated_attribute(proposal_component.participatory_space.title)})", proposal_component.id]
          end
          options_for_select(options, selected: content_block.settings.linked_components_id)
        end

        def options_for_default_component
          components = Decidim::Component.where(id: content_block.settings.linked_components_id.compact)
          options = components.map do |component|
            ["#{translated_attribute(component.name)} (#{translated_attribute(component.participatory_space.title)})", component.id]
          end
          options_for_select(options, selected: content_block.settings.default_linked_component)
        end

        def proposals_components
          @proposals_components ||= Decidim::Component.where(manifest_name: "proposals").published
        end

        def order_options
          [
            [I18n.t("most_recent", scope: "decidim.homepage_proposals.content_blocks.proposals_slider_settings_form.show"), "most_recent"],
            [I18n.t("least_recent", scope: "decidim.homepage_proposals.content_blocks.proposals_slider_settings_form.show"), "least_recent"],
            [I18n.t("random", scope: "decidim.homepage_proposals.content_blocks.proposals_slider_settings_form.show"), "random"]
          ]
        end
      end
    end
  end
end
