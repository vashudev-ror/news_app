// app/javascript/controllers/author_filter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category", "author"]

  // Optional: Call updateAuthors on connect if you want to initialize
  // the author dropdown based on a category pre-selected in URL params.
  // connect() {
  //   if (this.categoryTarget.value) {
  //     this.updateAuthors();
  //   }
  // }

  updateAuthors() {
    const selectedCategory = this.categoryTarget.value;

    fetch(`/articles/filtered_authors?category=${encodeURIComponent(selectedCategory)}`)
      .then(response => {
        if (!response.ok) { // Check for HTTP errors
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(authors => {
        this.authorTarget.innerHTML = ""; // Clear existing options

        // Always add the blank option at the top (matches include_blank: true in Rails)
        const blankOption = document.createElement("option");
        blankOption.value = "";
        blankOption.textContent = "";
        this.authorTarget.appendChild(blankOption);

        // Populate with actual authors returned from the backend
        authors.forEach(author => {
          const option = document.createElement("option");
          option.value = author;
          option.textContent = author;
          this.authorTarget.appendChild(option);
        });

        // --- Core Fix: Select the first author or remain blank ---
        if (authors.length > 0) {
          // Attempt to retain a previously selected author from URL params
          const currentAuthorParam = new URLSearchParams(window.location.search).get('author');
          if (currentAuthorParam && authors.includes(currentAuthorParam)) {
              this.authorTarget.value = currentAuthorParam;
          } else {
              // If no previous valid selection, select the first actual author from the list
              this.authorTarget.value = authors[0];
          }
        } else {
            // If no authors are returned for the category, ensure the blank option is selected
            this.authorTarget.value = "";
        }
        // --- End Core Fix ---

      })
      .catch(error => {
        console.error("Error fetching filtered authors:", error);
        // Add user-facing error message here if desired
      });
  }
}