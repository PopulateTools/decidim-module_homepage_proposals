import GlideBuilder from "../glideBuilder";
import GlideItem from "./glideItems/GlideItem";
import Proposal from "./glideItems/Proposal";
import NotFound from "./glideItems/NotFound";


// Manager communicates with API and build the HTML for the Glide.js carousel
// Example :
// let manager = new Manager($proposalsSlider, $proposalsGlideItems, $glideBullets, $formFilter)
// manager.start().then(() => manager.glide.mount())
//
// @return - Instance of Manager
export default class Manager {
    constructor($proposalsSlider, $proposalsGlideItems, $glideBullets, $formFilter, id) {
        this.$proposalSlider = $proposalsSlider;
        this.$proposalsGlideItems = $proposalsGlideItems;
        this.$glideBullets = $glideBullets;
        this.$formFilter = $formFilter;
        this.sliderId = id;
        this.$loading = this.$proposalSlider.find(".loading");
    }

    // @return String - API URL with filter params
    APIUrl() {
        return '/proposals_slider/refresh_proposals' + this.filterURIParams();
    }

    // @return String - Filter params query string
    filterURIParams() {
        const filterForm = this.$formFilter;
        const formAction = filterForm.attr("action");
        const params = filterForm.find("select:not(.ignore-filter)").serialize();
        const configParams = filterForm.find("input[data-filter-config]").serialize();

        let path = "";

        if (formAction.indexOf("?") < 0) {
            path = `${formAction}?${params}&${configParams}`;
        } else {
            path = `${formAction}&${params}&${configParams}`;
        }
        return path;
    }

    // Clears Glide carousel and display loader
    // @return void
    startLoading() {
        let height = $(".glide__slides").css("height");
        this.clearGlideItems();
        this.$loading.css("height", height);
        this.$loading.show();
    }

    // Hide loader
    // @return void
    endLoading() {
        this.$loading.hide();
    }

    sliderSelector() {
        return `#proposals-slider-${this.sliderId} .glide`;
    }

    // Clears glide items and glide bullets
    // @return void
    clearGlideItems() {
        this.$proposalsGlideItems.empty();
        $(".glide__bullet.glide__bullet_idx").remove()
    }

    // We must disable existing glide carousel before refresh
    // @return void
    disableGlide() {
        if (this.glide !== undefined) {
            this.glide.disable()
        }
    }

    // Send request to API and create items received in Glide.js carousel
    // @return this.glide
    start() {
        this.startLoading();
        this.disableGlide()

        $.get(this.APIUrl())
            .done((res) => {
                this.generateGlides(res)
            })
            .fail(() => {
                this.generateGlides([])
            })
            .always((res) => {
                // Use an infinite carousel if there are enough elements to fill pervView
                this.glide = new GlideBuilder(this.sliderSelector(), res.length >= GlideBuilder.defaultPervView() ? 'carousel' : 'slider');

                if (res.length === undefined || res.length <= 1 || res.status === 500) {
                    this.glide.disable()
                }
                this.endLoading();

                this.glide.mount()
            })
    }

    // Creates Glide Items
    // @return void
    generateGlides(res) {
        if (res.url) {
            this.createProposalsNotFound(res.url);
            return;
        }

        this.createProposals(res)
    }

    // Create Glide Items with:
    // - A Not Found GlideItem
    // - 3 placeholders
    // @return void
    createProposalsNotFound(url) {
        const notFoundGlide = new NotFound(url)
        this.$proposalsGlideItems.append(notFoundGlide.render())
        this.$glideBullets.find(".glide__bullet:last").before(notFoundGlide.bullet(0));

        for (let i = 0; i < GlideBuilder.defaultPervView() - 1; i++) {
            this.$proposalsGlideItems.append(notFoundGlide.placeholder());
        }
    }

    // Create Glide Items proposals, if proposals length is smaller than GlideBuilder.pervView() (default: 4)
    // Then it creates placeholders until reaching 4 Glide Items
    // @return void
    createProposals(proposals) {
        for (let i = 0; i < proposals.length; i++) {
            let proposalGlide = new Proposal(proposals[i])
            this.$proposalsGlideItems.append(proposalGlide.render());
            this.$glideBullets.find(".glide__bullet:last").before(proposalGlide.bullet(i));
        }
    }
}
