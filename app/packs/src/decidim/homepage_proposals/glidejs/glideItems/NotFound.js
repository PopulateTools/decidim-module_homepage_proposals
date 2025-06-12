import GlideItem from "./GlideItem";

export default class NotFound extends GlideItem {
    render() {
        return `<div class="column glide__slide">
<div class="card card--proposal card--stack">
  <div class="card--header"></div>
    <div class="card--content text-center margin-top-1">
      <h3 class="card__title">No match</h3>
      <div class="card__text--paragraph padding-top-1">
        <p>No proposals found for this request</p>
      </div>
    </div>
  </div>
</div>`
    }

}
