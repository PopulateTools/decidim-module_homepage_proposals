# frozen_string_literal: true

module Decidim
  class ProposalsSliderController < Decidim::ApplicationController
    include Decidim::FilterResource
    include Decidim::TranslatableAttributes
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::ComponentPathHelper
    include Decidim::LayoutHelper

    delegate :asset_pack_path, to: :action_controller_helpers
    def refresh_proposals
      render json: build_proposals_api
    end

    private

    def action_controller_helpers
      ActionController::Base.helpers
    end

    def proposal_state_css_class(proposal)
      return if proposal.state.blank?
      return proposal.proposal_state&.css_class if proposal.respond_to?(:proposal_state) && !roposal.emendation?
      return "info" unless proposal.published_state?

      case proposal.state
      when "accepted"
        "success"
      when "rejected", "withdrawn"
        "alert"
      when "evaluating"
        "warning"
      else
        "info"
      end
    end

    def proposal_complete_state(proposal)
      return humanize_proposal_state(proposal.state) unless proposal.respond_to?(:proposal_state)
      return humanize_proposal_state("not_answered").html_safe if proposal.proposal_state.nil?
      return humanize_proposal_state("not_answered").html_safe unless proposal.published_state?

      translated_attribute(proposal&.proposal_state&.title)
    end

    def humanize_proposal_state(state)
      I18n.t(state, scope: "decidim.proposals.answers", default: :not_answered)
    end

    def state_settings(proposal)
      state_18n = if Decidim.module_installed?(:custom_proposal_states) || proposal.respond_to?(:proposal_state)
                    proposal_complete_state(proposal)
                  else
                    humanize_proposal_state(proposal.state)
                   end

      {
        state: proposal.state,
        state_css_class: proposal_state_css_class(proposal),
        state_i18n: state_18n
      }
    end

    def build_proposals_api
      return component_url unless glanced_proposals.any?

      glanced_proposals.flat_map do |proposal|
        {
          id: proposal.id,
          title: translated_attribute(proposal.title).truncate(40),
          body: translated_attribute(proposal.body).truncate(150),
          url: proposal_path(proposal),
          image: image_for(proposal),
          tags: proposal.category ? cell("decidim/homepage_proposals/tags", proposal).to_s.strip.html_safe : ""
        }.merge(state_settings(proposal))
      end
    end

    def glanced_proposals
      if params[:filter].present?
        category = Decidim::Category.find(params.dig(:filter, :category_id)) if params.dig(:filter, :category_id).present?
        scopes = Decidim::Scope.find(params.dig(:filter, :scope_id)) if params.dig(:filter, :scope_id).present?
      end

      @glanced_proposals ||= sorted_query(
        base_query(component: params.dig(:filter, :component_id), category:, scopes:),
        **filter_config
      )
    end

    def base_query(component:, scopes: nil, category: nil)
      query = Decidim::Proposals::Proposal.not_rejected.not_withdrawn.published.where(component:).where(filter_by_scopes(scopes))
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
      @filter_config ||= { "order" => "random", "max_results" => 12 }.merge(params[:filter_config]&.permit(:order, :max_results).to_h).symbolize_keys
    end

    def proposal_path(proposal)
      Decidim::ResourceLocatorPresenter.new(proposal).path
    end

    def image_for(proposal)
      return external_icon("media/images/placeholder-card-g.svg", class: "card__placeholder-g").to_s unless proposal.attachments.select(&:image?).any?

      image_tag(proposal.attachments.select(&:image?).first&.url, class: "card__grid-img")
    end

    def component_url
      return { url: "/" } if params.dig(:filter, :component_id).blank?

      begin
        { url: main_component_path(Decidim::Component.find(params.dig(:filter, :component_id))) }
      rescue ActiveRecord::RecordNotFound
        { url: "/" }
      end
    end
  end
end
