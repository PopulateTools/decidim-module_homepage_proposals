# frozen_string_literal: true

module Decidim
  module HomepageProposals
    # This is the engine that runs on the public interface of `HomepageProposals`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::HomepageProposals::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Create a route to refresh proposals
        # proposals_slider/refresh_proposals searching for the method "refresh_proposals" in the cell
        # resources :homepage_proposals
        # root to: "homepage_proposals#index"
      end

      def load_seed
        nil
      end

      config.to_prepare do
        Decidim::Admin::ContentBlockCell.include(Decidim::HomepageProposals::Admin::ContentBlockCellCustomization)
      end
    end
  end
end
