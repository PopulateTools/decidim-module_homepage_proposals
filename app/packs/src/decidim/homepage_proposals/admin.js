import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const config = {
    plugins: ["remove_button", "dropdown_input"],
    allowEmptyOption: true
  };
  const linkedComponentsMultiselectContainers = document.querySelectorAll(
    ".js-linked-components-multiselect"
  );

  linkedComponentsMultiselectContainers.forEach((container) => new TomSelect(container, config));
});

$(document).ready(function() {
    $('#content_block_settings_linked_components_id').on('change', function() {
        var selectedOptions = $(this).val(); // Get the selected options from the multiselect field
        var $selectedOptionsField = $('#content_block_settings_default_linked_component'); // Get the select field for the selected options

        $selectedOptionsField.empty(); // Clear the select field

        // Add the selected options to the select field
        if (selectedOptions && selectedOptions.length > 0) {
            selectedOptions.forEach(function(option) {
                var optionText = $('#content_block_settings_linked_components_id option[value="' + option + '"]').text();
                $selectedOptionsField.append($('<option>', { value: option, text: optionText }));
            });
        }
    });
});
