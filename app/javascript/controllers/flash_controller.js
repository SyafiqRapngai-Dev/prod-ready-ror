import { Controller } from "@hotwired/stimulus";

// Auto-dismisses flash messages after a configurable duration.
// Usage: data-controller="flash" data-flash-duration-value="4000"
export default class extends Controller {
  static values = { duration: { type: Number, default: 4000 } };

  connect() {
    this.timer = setTimeout(() => this.dismiss(), this.durationValue);
  }

  disconnect() {
    clearTimeout(this.timer);
  }

  dismiss() {
    this.element.style.transition = "opacity 0.3s ease";
    this.element.style.opacity = "0";
    setTimeout(() => this.element.remove(), 350);
  }
}
