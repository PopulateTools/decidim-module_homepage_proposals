# frozen_string_literal: true

module Decidim
  module HomepageProposals
    module ContentBlocks
      class ProposalsSliderCell < Decidim::ContentBlocks::BaseCell
        attr_accessor :glanced_proposals

        delegate :settings, to: :model

        include Cell::ViewModel::Partial
        include Core::Engine.routes.url_helpers
        include Decidim::IconHelper
        include ActionView::Helpers::FormOptionsHelper
        include Decidim::FiltersHelper
        include Decidim::FilterResource
        include Decidim::ComponentPathHelper
        include Decidim::ScopesHelper

        def default_linked_component_path
          main_component_path(Decidim::Component.find(selected_component_id))
        rescue ActiveRecord::RecordNotFound
          root_path
        end

        def options_for_default_component
          options = linked_components.map do |component|
            ["#{translated_attribute(component.name)} (#{translated_attribute(component.participatory_space.title)})", component.id]
          end

          options_for_select(options, selected: selected_component_id)
        end

        def linked_components
          @linked_components ||= Decidim::Component.where(id: settings.linked_components_id.compact)
        end

        def default_filter_params
          {
            scope_id: nil,
            category_id: nil,
            component_id: nil
          }
        end

        def categories_filter
          @categories_filter ||= Decidim::Category.where(id: available_categories_ids)
        end

        def filters
          render :filters
        end

        def selected_component_id
          @selected_component_id ||= params.dig(:filter, :component_id) || settings.default_linked_component
        end

        def selected_category_id
          params.dig(:filter, :category_id)&.to_i
        end

        def available_categories_ids
          categories_ids = base_proposals_relation.joins(:category).select("decidim_categorizations.decidim_category_id").distinct.map(&:decidim_category_id)
          categories_ids << selected_category_id if selected_category_id.present? && categories_ids.exclude?(selected_category_id)
          categories_ids
        end

        def order_config
          settings.order.presence || "random"
        end

        def max_results_config
          settings.max_results.presence || 12
        end

        def view_all_text_config
          translated_attribute(settings.view_all_text).presence || I18n.t("decidim.homepage_proposals.proposal_at_a_glance.filters.all_proposals")
        end

        def view_all_url_config
          return default_linked_component_path if settings.view_all_url.blank?

          URI.parse(settings.view_all_url).to_s
        rescue URI::InvalidURIError
          default_linked_component_path
        end

        def title
          translated_attribute(settings.block_title).presence || I18n.t("decidim.homepage_proposals.proposal_at_a_glance.title")
        end

        def data
          { proposals_slider: model.id }
        end

        def base_proposals_relation
          Decidim::Proposals::Proposal.not_status(:rejected).not_withdrawn.published.where(component: selected_component_id)
        end
      end
    end
  end
end
