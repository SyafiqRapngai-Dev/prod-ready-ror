import { Controller } from "@hotwired/stimulus";

// Toggles the notification dropdown panel.
// Usage: data-controller="notification" on the wrapper div.
export default class extends Controller {
  static targets = ["dropdown"];

  connect() {
    this.isOpen = false;
    // Close on outside click
    this.handleOutsideClick = this.handleOutsideClick.bind(this);
  }

  toggle() {
    this.isOpen ? this.close() : this.open();
  }

  open() {
    this.isOpen = true;
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.remove("hidden");
    }
    document.addEventListener("click", this.handleOutsideClick);
  }

  close() {
    this.isOpen = false;
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.add("hidden");
    }
    document.removeEventListener("click", this.handleOutsideClick);
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close();
    }
  }
}
