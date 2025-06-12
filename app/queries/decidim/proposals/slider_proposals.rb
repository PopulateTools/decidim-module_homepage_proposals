# frozen_string_literal: true

module Decidim
  module Proposals
    # A class used to find proposals filtered by components and a date range
    class SliderProposals < Decidim::Query
      def self.for(components)
        new(components).query
      end

      def initialize(components)
        @components = components
      end

      def query
        with_state_not_rejected.or(without_state_not_answered)
      end

      private

      def with_state_not_rejected
        base_join.where.not(decidim_proposals_proposal_states: { token: :rejected })
      end

      def without_state_not_answered
        base_join.where(decidim_proposals_proposal_state_id: nil, answered_at: nil)
      end

      def base_join
        FilteredProposals.for(@components).not_withdrawn.published.left_outer_joins(:proposal_state)
      end
    end
  end
end
