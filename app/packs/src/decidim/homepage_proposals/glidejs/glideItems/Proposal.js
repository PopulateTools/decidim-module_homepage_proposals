import GlideItem from "./GlideItem";

export default class Proposal extends GlideItem {
    constructor(obj) {
        super();
        this.displayBody = obj.hasOwnProperty("body");
        this.displayImage = obj.hasOwnProperty("image");
        this.displayState = obj.hasOwnProperty("state_i18n");
        this.title = obj.title;
        if (this.displayBody) {
            this.body = obj.body;
        }
        if (this.displayImage) {
            this.image = obj.image;
        }
        this.url = obj.url;
        if (this.displayState) {
            this.stateI18n = obj.state_i18n;
            this.color = obj.state_css_class;
            this.style = obj.state_css_style;
        }
        this.tags = obj.tags;
    }

    getTagsTemplate() {
        return `<ul class="tags tags--proposal">
    ${this.tags}
</ul>`
    }

    render() {
        return `<a href="${this.url}" class="card__grid glide__slide">
      ${this.imagePartial()}
      <div class="card__grid-text">
        ${this.statePartial()}
        ${this.titlePartial()}
        ${this.getTagsTemplate()}
        ${this.bodyPartial()}
      </div>
    </a>`
    }

    titlePartial() {
        return `<h3 class="h4 text-secondary">${this.title}</h3>`;
    }
    imagePartial() {
        if (this.displayImage) {
            return `<div class="card__grid-img">
        ${this.image}
      </div>`;
        } else {
            return "";
        }
    }

    bodyPartial() {
        if (this.displayBody) {
            return `<p>${this.body}</p>`;
        } else {
            return "";
        }
    }

    statePartial() {
        if (this.displayState) {
            return `<div class="card__list-metadata">
          <span class="label ${this.color}" style="${this.style}"> ${this.stateI18n} </span>
        </div>`
        } else {
            return "";
        }
    }

}
