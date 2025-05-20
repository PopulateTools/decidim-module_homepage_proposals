import Manager from "./glidejs/Manager"

// Build GlideJS carousel in the content block
// Tree
// ./glideBuilder.js - Build a new instance of GlideJS carousel with options based on current number of proposals found
// ./glidejs/Manager.js - Start, Refresh, Stop GlideJS carousel, creates proposals cards items in carousel
// ./glidejs/glideitems/* - GlideJS items to render
$("[data-proposals-slider]").each((_i, elem) => {
    const id = elem.dataset.proposalsSlider;
    const $block = $(elem);

    const $proposalsSlider = $(`#proposals-slider-${id}`);
    const $proposalsGlideItems = $(`#proposals-glide-items-${id}`);
    const $filterForm = $(`#filters-form-${id}`);
    const slider = new Manager($proposalsSlider, $proposalsGlideItems, $block.find(".glide__bullets"), $filterForm, id);
    slider.start()

    // Refresh slider when Desktop filter form changes
    $filterForm.on("change", (event) => {
        slider.start();

        $.get(slider.FilterUrl())
            .done((res) => {
                const div = document.createElement("div");
                const filtersContainer = slider.$formFilter.find("[data-filters-container]")

                div.innerHTML = res;
                const filtersContainerReplacement = div.querySelector("[data-filters-container]");
                filtersContainer.replaceWith(filtersContainerReplacement)

                const viewAllUrlConfig = div.querySelector("input[data-view-all-url-config]").dataset.viewAllUrlConfig;

                if (viewAllUrlConfig !== undefined) {
                    const viewAllLink = document.querySelector(`[data-proposals-slider='${slider.sliderId}'] [data-view-all-link]`);
                    if (viewAllLink) {
                        viewAllLink.setAttribute("href", viewAllUrlConfig);
                    }
                }
                div.remove();
            });
    });
});
