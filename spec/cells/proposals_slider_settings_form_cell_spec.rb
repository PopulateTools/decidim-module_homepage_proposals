# frozen_string_literal: true

require "spec_helper"

module Decidim
  module HomepageProposals
    module ContentBlocks
      describe ProposalsSliderSettingsFormCell, type: :cell do
        include Decidim::TranslatableAttributes

        subject { cell("decidim/homepage_proposals/content_blocks/proposals_slider_settings_form") }

        let!(:current_organization) { create(:organization) }
        let!(:activate_filters) { false }
        let!(:linked_components_id) { [] }
        let!(:default_linked_component) { nil }
        let!(:content_block) do
          create(:content_block,
                 manifest_name: "proposals_slider",
                 organization: current_organization,
                 settings: { activate_filters: activate_filters,
                             linked_components_id: linked_components_id,
                             default_linked_component: default_linked_component })
        end

        before do
          allow(subject).to receive(:current_organization).and_return(current_organization)
          allow(subject).to receive(:content_block).and_return(content_block)
        end

        context "when there are no proposals components" do
          it "returns an empty array" do
            expect(subject.options_for_proposals_components).to eq("")
            expect(subject.options_for_default_component).to eq("")
          end
        end

        context "when there are proposals components" do
          let!(:proposals_component) { create(:proposal_component, :published, organization: current_organization) }
          let!(:proposals_component2) { create(:proposal_component, :published, organization: current_organization) }
          let!(:proposals_component3) { create(:proposal_component, :published, organization: current_organization) }
          let!(:linked_components_id) { [proposals_component.id, proposals_component2.id] }
          let!(:default_linked_component) { proposals_component.id }

          it "returns an array with the proposals components" do
            expect(subject.options_for_proposals_components).to include("<option selected=\"selected\" value=\"#{proposals_component.id}\">#{decidim_escape_translated(proposals_component.name)} (#{decidim_escape_translated(proposals_component.participatory_space.title)})</option>")
            expect(subject.options_for_proposals_components).to include("<option selected=\"selected\" value=\"#{proposals_component2.id}\">#{decidim_escape_translated(proposals_component2.name)} (#{decidim_escape_translated(proposals_component2.participatory_space.title)})</option>")
            expect(subject.options_for_proposals_components).to include("<option value=\"#{proposals_component3.id}\">#{decidim_escape_translated(proposals_component3.name)} (#{decidim_escape_translated(proposals_component3.participatory_space.title)})</option>")

            expect(subject.options_for_default_component).to include("<option selected=\"selected\" value=\"#{proposals_component.id}\">#{decidim_escape_translated(proposals_component.name)} (#{decidim_escape_translated(proposals_component.participatory_space.title)})</option>")
            expect(subject.options_for_default_component).to include("<option value=\"#{proposals_component2.id}\">#{decidim_escape_translated(proposals_component2.name)} (#{decidim_escape_translated(proposals_component2.participatory_space.title)})</option>")
          end
        end
      end
    end
  end
end
