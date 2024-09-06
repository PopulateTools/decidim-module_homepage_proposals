# frozen_string_literal: true

require "spec_helper"

describe "Homepage proposals slider", type: :system, js: true do
  include Decidim::TranslatableAttributes

  let(:organization) { create(:organization) }
  let!(:hero) { create :content_block, organization: organization, scope_name: :homepage, manifest_name: :hero }
  let!(:slider) { create :proposals_slider, organization: organization }

  before do
    switch_to_host(organization.host)
  end

  context "when has no settings" do
    it "does not display the slider" do
      visit decidim.root_path

      expect(page).not_to have_content("Proposals slider")
    end
  end

  context "when has a default component" do
    let!(:component) { create :proposal_component, organization: organization }
    let!(:proposals) { create_list :proposal, 12, component: component, skip_injection: true }
    let!(:slider) { create :proposals_slider, organization: organization, settings: { linked_components_id: [component.id], default_linked_component: component.id } }

    it "displays the slider but not the filters" do
      visit decidim.root_path

      expect(page).to have_content("EXPLORE PROPOSALS")
      expect(page).not_to have_css(".filters")
    end

    context "and filters" do
      let!(:slider) { create :proposals_slider, organization: organization, settings: { linked_components_id: [component.id], default_linked_component: component.id, activate_filters: true } }

      it "displays the slider and the filters" do
        visit decidim.root_path

        expect(page).to have_content("EXPLORE PROPOSALS")
        expect(page).to have_css(".filters")
      end

      context "when using the filters" do
        let!(:slider) { create :proposals_slider, organization: organization, settings: { linked_components_id: [component.id, other_component.id], default_linked_component: component.id, activate_filters: true } }
        let!(:other_component) { create(:proposal_component, organization: organization) }
        let!(:category1) { create(:category, participatory_space: other_component.participatory_space) }
        let!(:category2) { create(:category, participatory_space: other_component.participatory_space) }
        let!(:category3) { create(:category, participatory_space: other_component.participatory_space) }
        let!(:scope1) { create(:scope, organization: organization) }
        let!(:scope2) { create(:scope, organization: organization) }
        let!(:proposals11) { create_list(:proposal, 1, component: other_component, category: category1, scope: scope1, skip_injection: true) }
        let!(:proposals12) { create_list(:proposal, 1, component: other_component, category: category1, scope: scope2, skip_injection: true) }
        let!(:proposals21) { create_list(:proposal, 1, component: other_component, category: category2, scope: scope1, skip_injection: true) }
        let!(:proposals22) { create_list(:proposal, 1, component: other_component, category: category2, scope: scope2, skip_injection: true) }
        let!(:proposals31) { create_list(:proposal, 1, component: other_component, category: category3, scope: scope1, skip_injection: true) }
        let!(:proposals32) { create_list(:proposal, 1, component: other_component, category: category3, scope: scope2, skip_injection: true) }

        context "when filtering to render nothing" do
          it "displays the not found proposals with the component link" do
            visit decidim.root_path
            select translated_attribute(category1.name), from: "filter[category_id]"

            expect(page).to have_content("No proposals found")
            expect(page).to have_link("Visit proposals", href: main_component_path(component))
          end
        end

        context "when filtering by another component" do
          it "displays only the proposals of this component" do
            visit decidim.root_path
            select "#{translated_attribute(other_component.name)} (#{translated_attribute(other_component.participatory_space.title)})", from: "filter[component_id]"

            expect(page).to have_css(".glide__bullet_idx", count: 6)
          end

          context "and by a category" do
            it "displays only the proposals of this category" do
              visit decidim.root_path
              expect(page).to have_css(".glide__bullet_idx", count: 12)
              select "#{translated_attribute(other_component.name)} (#{translated_attribute(other_component.participatory_space.title)})", from: "filter[component_id]"
              expect(page).to have_css(".glide__bullet_idx", count: 6)
              select translated_attribute(category1.name), from: "filter[category_id]"
              expect(page).to have_css(".glide__bullet_idx", count: 2)
              expect(page).to have_content(translated_attribute(proposals11.first.title))
              expect(page).to have_content(translated_attribute(proposals12.first.title))
            end
          end

          context "and by a scope" do
            it "displays only the proposals of this scope" do
              visit decidim.root_path
              select translated_attribute(scope1.name), from: "filter[scope_id]"
              select "#{translated_attribute(other_component.name)} (#{translated_attribute(other_component.participatory_space.title)})", from: "filter[component_id]"

              expect(page).to have_css(".glide__bullet_idx", count: 3)
              expect(page).to have_content(translated_attribute(proposals11.first.title))
              expect(page).to have_content(translated_attribute(proposals21.first.title))
              expect(page).to have_content(translated_attribute(proposals31.first.title))
            end
          end

          context "and by a category and a scope" do
            it "displays only the proposals of this category and scope" do
              visit decidim.root_path
              select translated_attribute(scope1.name), from: "filter[scope_id]"
              select translated_attribute(category1.name), from: "filter[category_id]"
              select "#{translated_attribute(other_component.name)} (#{translated_attribute(other_component.participatory_space.title)})", from: "filter[component_id]"

              expect(page).to have_css(".glide__bullet_idx", count: 1)
              expect(page).to have_content(translated_attribute(proposals11.first.title))
            end
          end
        end
      end
    end
  end
end
