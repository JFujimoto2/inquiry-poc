import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["accommodation", "breakfastWrapper"]

  toggleBreakfast() {
    if (this.accommodationTarget.checked) {
      this.breakfastWrapperTarget.classList.remove("hidden")
    } else {
      this.breakfastWrapperTarget.classList.add("hidden")
      const breakfastCheckbox = this.breakfastWrapperTarget.querySelector("input[type=checkbox]")
      if (breakfastCheckbox) {
        breakfastCheckbox.checked = false
      }
    }
  }
}
