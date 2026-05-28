import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image", "caption"]

  connect() {
    this.modalInstance = null
  }

  open(event) {
    const { srcParam, altParam } = event.params
    if (!srcParam || !this.hasModalTarget || !this.hasImageTarget) return

    this.imageTarget.src = srcParam
    this.imageTarget.alt = altParam || "Expanded image"

    if (this.hasCaptionTarget) {
      this.captionTarget.textContent = altParam || ""
      this.captionTarget.classList.toggle("d-none", !altParam)
    }

    this.modal().show()
  }

  modal() {
    if (!this.modalInstance) {
      this.modalInstance = new window.bootstrap.Modal(this.modalTarget)
    }

    return this.modalInstance
  }
}
