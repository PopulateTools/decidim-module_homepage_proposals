# frozen_string_literal: true

module Decidim
  module HomepageProposals
    module Admin
      module ContentBlockCellCustomization
        extend ActiveSupport::Concern

        included do
          alias_method :decidim_name, :name

          def name
            attribute_name = custom_title_attribute
            return decidim_name if attribute_name.blank?

            [decidim_name, translated_attribute(model.settings.send(attribute_name)).presence].compact.join(" - ")
          end

          private

          def custom_title_attribute
            return unless has_settings?
            return if model.settings_form_cell.blank?

            cell = Decidim::ViewModel.cell(model.settings_form_cell)
            return unless cell.respond_to?(:content_block_name_attribute)

            cell.content_block_name_attribute
          end
        end
      end
    end
  end
end
