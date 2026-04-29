import { Controller } from "@hotwired/stimulus";

// Wraps a <dialog> element for modal behavior.
// Usage: data-controller="modal" on the dialog element.
// Close button: data-action="modal#close"
// Open via Turbo Frame loading content into the dialog's turbo-frame.
export default class extends Controller {
  connect() {
    this.element.addEventListener("click", this.handleBackdropClick.bind(this));
    document.addEventListener("keydown", this.handleEscape.bind(this));
    this.element.showModal();
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleEscape.bind(this));
  }

  close() {
    this.element.close();
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }

  handleBackdropClick(event) {
    // Close if click is outside the dialog content (on the backdrop)
    const rect = this.element.getBoundingClientRect();
    const isOutside =
      event.clientX < rect.left ||
      event.clientX > rect.right ||
      event.clientY < rect.top ||
      event.clientY > rect.bottom;
    if (isOutside) this.close();
  }
}
