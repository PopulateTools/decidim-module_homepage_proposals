# frozen_string_literal: true

module Decidim
  class ProposalsSliderController < Decidim::ApplicationController
    include Decidim::FilterResource
    include Decidim::TranslatableAttributes
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::ComponentPathHelper
    include Decidim::LayoutHelper
    include Decidim::Proposals::ApplicationHelper

    delegate :asset_pack_path, to: :action_controller_helpers
    attr_reader :content_block

    before_action :set_content_block

    def refresh_proposals
      render json: build_proposals_api
    end

    def filters
      render layout: false
    end

    private

    def action_controller_helpers
      ActionController::Base.helpers
    end

    def proposal_complete_state(proposal)
      return humanize_proposal_state(proposal.state) unless proposal.respond_to?(:proposal_state)
      return humanize_proposal_state("not_answered").html_safe if proposal.proposal_state.nil?
      return humanize_proposal_state("not_answered").html_safe unless proposal.published_state?

      translated_attribute(proposal&.proposal_state&.title)
    end

    def state_settings(proposal)
      {
        state_i18n: proposal_complete_state(proposal),
        state_css_class: proposal_state_css_class(proposal),
        state_css_style: proposal_state_css_style(proposal)
      }
    end

    def build_proposals_api
      return component_url unless glanced_proposals.any?

      display_body = content_block&.settings.present? ? content_block.settings.display_proposals_body : true
      display_image = content_block&.settings.present? ? content_block.settings.display_proposals_image : true
      display_state = content_block&.settings.present? ? content_block.settings.display_proposals_state : true

      glanced_proposals.flat_map do |proposal|
        data =  {
          id: proposal.id,
          title: title_for(proposal),
          url: proposal_path(proposal),
          tags: proposal.category ? cell("decidim/homepage_proposals/tags", proposal).to_s.strip.html_safe : ""
        }

        data.merge!(body: body_for(proposal)) if display_body
        data.merge!(image: image_for(proposal)) if display_image
        data.merge!(state_settings(proposal)) if display_state

        data
      end
    end

    def glanced_proposals
      if filter_params.present?
        category = Decidim::Category.find(filter_params[:category_id]) if filter_params[:category_id].present?
        scopes = Decidim::Scope.find(filter_params[:scope_id]) if filter_params[:scope_id].present?
      end

      @glanced_proposals ||= sorted_query(
        base_query(component: components_ids, category:, scopes:),
        **filter_config.except(:content_block)
      )
    end

    def base_query(component:, scopes: nil, category: nil)
      query = Decidim::Proposals::Proposal.not_status(:rejected).not_withdrawn.published.where(component:).where(filter_by_scopes(scopes))
      return query.with_category(category) if category.present?

      query
    end

    def sorted_query(query, order:, max_results:)
      limit = max_results.to_i
      case order
      when "random"
        query.sample(limit)
      when "most_recent"
        query.order(created_at: :desc).limit(limit)
      when "least_recent"
        query.order(created_at: :asc).limit(limit)
      end
    end

    def filter_by_scopes(scopes)
      { scope: scopes } if scopes.present?
    end

    def filter_config
      @filter_config ||= { "order" => "random", "max_results" => 12 }.merge(params[:filter_config]&.permit(:order, :max_results, :content_block).to_h).symbolize_keys
    end

    def proposal_path(proposal)
      Decidim::ResourceLocatorPresenter.new(proposal).path
    end

    def image_for(proposal)
      return external_icon("media/images/placeholder-card-g.svg", class: "card__placeholder-g").to_s unless proposal.attachments.select(&:image?).any?

      ActionController::Base.helpers.image_tag(proposal.attachments.select(&:image?).first&.url, class: "card__grid-img")
    end

    def title_for(proposal)
      title = translated_attribute(proposal.title)
      return title if title_max_length.zero?

      title.truncate(title_max_length)
    end

    def body_for(proposal)
      body = Decidim::Proposals::ProposalPresenter.new(proposal).body(strip_tags: true)
      return body if body_max_length.zero?

      body.truncate(body_max_length)
    end

    def set_content_block
      @content_block = Decidim::ContentBlock.find_by(id: filter_config[:content_block])
    end

    def title_max_length
      @title_max_length ||= content_block&.settings&.max_length_of_title&.positive? ? content_block.settings.max_length_of_title : 0
    end

    def body_max_length
      @body_max_length ||= content_block&.settings&.max_length_of_body&.positive? ? content_block.settings.max_length_of_body : 0
    end

    def component_url
      return { url: "/" } if params.dig(:filter, :component_id).blank?

      begin
        { url: main_component_path(Decidim::Component.find(params.dig(:filter, :component_id))) }
      rescue ActiveRecord::RecordNotFound
        { url: "/" }
      end
    end

    def components_ids
      @components_ids ||= filter_params[:component_id] || content_block.settings.linked_components_id&.compact_blank
    end

    def filter_params
      @filter_params ||= params[:filter].present? ? params.require(:filter).permit(:component_id, :content_block, :category_id, :scope_id) : {}
    end
  end
end
