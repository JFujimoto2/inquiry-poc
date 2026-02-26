import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["accommodation", "breakfastWrapper", "startDate", "endDate", "dateError"]

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

  validateDateRange() {
    if (!this.hasStartDateTarget || !this.hasEndDateTarget) return

    const startDate = this.startDateTarget.value
    const endDate = this.endDateTarget.value

    if (startDate && endDate && endDate < startDate) {
      this.dateErrorTarget.classList.remove("hidden")
      this.endDateTarget.setCustomValidity("利用終了日は利用開始日以降の日付を指定してください")
    } else {
      this.dateErrorTarget.classList.add("hidden")
      this.endDateTarget.setCustomValidity("")
    }
  }
}
