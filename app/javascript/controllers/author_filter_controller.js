import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category", "author"]

  connect() {}

  updateAuthors() {
    const selectedCategory = this.categoryTarget.value

    fetch(`/filtered_authors?category=${encodeURIComponent(selectedCategory)}`)
      .then(response => response.json())
      .then(authors => {
        this.authorTarget.innerHTML = ""

        authors.forEach(author => {
          const option = document.createElement("option")
          option.value = author
          option.textContent = author
          this.authorTarget.appendChild(option)
        })
      })
  }
}
