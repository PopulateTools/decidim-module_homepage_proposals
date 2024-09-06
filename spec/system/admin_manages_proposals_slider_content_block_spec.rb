# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals slider content blocks", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when trying to editate content blocks" do
    it "shows the proposals slider one" do
      visit decidim_admin.edit_organization_homepage_path

      click_on "Add content block"
      within "#add-content-block-dropdown" do
        expect(page).to have_content("Proposals slider")
      end
    end

    context "when editing a persisted content block" do
      let!(:content_block) { create :content_block, organization: organization, manifest_name: :proposals_slider, scope_name: :homepage }
      let!(:proposals_component1) { create :component, manifest_name: "proposals" }
      let!(:proposals_component2) { create :component, manifest_name: "proposals" }
      let!(:proposals_component3) { create :component, manifest_name: "proposals" }
      let!(:proposals_component4) { create :component }
      let!(:proposals) { create_list(:proposal, 12, component: proposals_component3) }

      it "updates the settings of the content block" do
        visit decidim_admin.edit_organization_homepage_content_block_path(content_block)

        check "Activate filters"

        within "#content_block_settings_linked_components_id" do
          find("option[value='#{proposals_component1.id}']").click
          find("option[value='#{proposals_component3.id}']").click
          expect(page).not_to have_css("option[value='#{proposals_component4.id}']")
        end

        within "#content_block_settings_default_linked_component" do
          expect(page).to have_selector("option[value='#{proposals_component1.id}']")
          find("option[value='#{proposals_component3.id}']").click
          expect(page).not_to have_css("option[value='#{proposals_component2.id}']")
        end

        click_button "Update"

        expect(content_block.reload.settings.activate_filters).to be(true)
        expect(content_block.reload.settings.linked_components_id).to eq(["", proposals_component1.id.to_s, proposals_component3.id.to_s])
        expect(content_block.reload.settings.default_linked_component).to eq(proposals_component3.id.to_i)
      end
    end
  end
end
