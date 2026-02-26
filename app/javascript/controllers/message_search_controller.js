import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    query: String
  }

  connect() {
    if (!this.hasQueryValue || !this.queryValue.trim()) return

    requestAnimationFrame(() => this.jumpToFirstMatch())
  }

  jumpToFirstMatch() {
    const matches = this.element.querySelectorAll('[data-search-match="true"]')
    if (!matches.length) return

    const firstMatch = matches[0]
    firstMatch.classList.add("search-current-hit")
    firstMatch.scrollIntoView({ behavior: "smooth", block: "center" })
  }
}
