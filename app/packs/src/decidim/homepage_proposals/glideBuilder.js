import Glide from "@glidejs/glide";

// Create a GlideJS carousel
// See documentation: https://glidejs.com/docs/
export default class GlideBuilder {
    static defaultPervView() {
        return 4;
    }

    static defaultBreakpoints() {
        return { 1024: { perView: 3 }, 768: { perView: 2 }, 480: { perView: 1 } };
    }

    constructor(selector = '.glide', type = 'carousel', pervView = GlideBuilder.defaultPervView()) {
        this.type = type
        this.pervView = pervView;
        this.breakpoints = this.setBreakpoints();
        this.setOpts()
        this.glide = new Glide(selector, this.options)

        this.bindings()
    }

    // Glide breakpoints must be accorded to the pervView to prevent scrolling on placeholders
    setBreakpoints() {
        let breakpoints;
        switch (this.pervView) {
            case 2:
                breakpoints = { 1024: {perView: 2}, 768: {perView: 2}, 480: {perView: 1} };
                break;
            case 1:
                breakpoints = { 1024: {perView: 1}, 768: {perView: 1}, 480: {perView: 1} };
                break;
            default:
                breakpoints = GlideBuilder.defaultBreakpoints();
        }
        return breakpoints;
    }

    destroy() {
        this.glide.destroy();
    }

    disable() {
        this.glide.disable();
    }

    mount() {
        this.glide.mount()
    }

    bindings() {
    this.glide.on("run", () => {
            let bulletNumber = this.glide.index;
            let $glideBullets = $(this.glide.selector).find(".glide__bullets");

            $($glideBullets.children()).css("color", "lightgrey");
            $($glideBullets.children().get(bulletNumber + 1)).css("color", "grey");
        });
    }

    setOpts() {
        this.options = {
            type: this.type,
            startAt: 0,
            autoplay: 0,
            perView: this.pervView,
            breakpoints: this.breakpoints,
            hoverpause: true,
            perTouch: 1
        }
    }
}
