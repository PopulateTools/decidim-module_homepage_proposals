# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module HomepageProposals
    # This is the engine that runs on the public interface of homepage_proposals.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::HomepageProposals

      routes do
        # Add engine routes here
        # resources :homepage_proposals
        # root to: "homepage_proposals#index"
      end

      initializer "HomepageProposals.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_homepage_proposals.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::HomepageProposals::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::HomepageProposals::Engine.root}/app/views") # for proposal partials
      end

      initializer "decidim_homepage_proposals.content_blocks" do
        Decidim.content_blocks.register(:homepage, :proposals_slider) do |content_block|
          content_block.cell = "decidim/homepage_proposals/content_blocks/proposals_slider"
          content_block.public_name_key = "decidim.homepage_proposals.content_blocks.proposals_slider.name"
          content_block.settings_form_cell = "decidim/homepage_proposals/content_blocks/proposals_slider_settings_form"
          content_block.settings do |settings|
            settings.attribute :activate_filters, type: :boolean, default: false
            settings.attribute :linked_components_id, type: :array
            settings.attribute :default_linked_component, type: :integer
            settings.attribute :order, type: :string
            settings.attribute :max_results, type: :integer, default: 12
          end
        end
      end
    end
  end
end
