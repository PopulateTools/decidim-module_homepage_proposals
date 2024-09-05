import GlideItem from "./GlideItem";

export default class Proposal extends GlideItem {
    constructor(obj) {
        super();
        this.title = obj.title;
        this.body = obj.body;
        this.image = obj.image;
        this.url = obj.url;
        this.state = obj.state || 'not answered' ;
        this.stateI18n = obj.state_i18n;
        this.color = obj.state_css_class;
        this.tags = obj.tags;
    }

    getTagsTemplate() {
        return `<ul class="tags tags--proposal">
    ${this.tags}
</ul>`
    }

    render() {
        return `<a href="${this.url}" class="card__grid glide__slide">
      <div class="card__grid-img">
        <img src="${this.image}" class="card__grid-img" alt="slider_img">
      </div>
      <div class="card__grid-text">
        <div class="card__list-metadata">
          <span class="label ${this.color}"> ${this.stateI18n} </span>
        </div>
        <h3 class="h4 text-secondary">${this.title}</h3>

          ${this.getTagsTemplate()}
        <p>${this.body}</p>

      </div>
    </a>`
    }

}
