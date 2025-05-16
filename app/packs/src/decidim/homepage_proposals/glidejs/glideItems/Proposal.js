import GlideItem from "./GlideItem";

export default class Proposal extends GlideItem {
    constructor(obj) {
        super();
        this.title = obj.title;
        this.body = obj.body;
        this.image = obj.image;
        this.url = obj.url;
        this.stateI18n = obj.state_i18n;
        this.color = obj.state_css_class;
        this.style = obj.state_css_style;
        this.tags = obj.tags;
        this.displayState = obj.display_state;
        this.displayBody = obj.display_body;
        this.displayImage = obj.display_image;
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
