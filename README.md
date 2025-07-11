# News App

This is a Ruby on Rails application designed for Browse news articles, featuring user authentication, dynamic filtering capabilities, and historical like count visualization.

## Overview

The News App provides a platform to explore a collection of news articles. Users can sign up and log in to access content, which can be filtered dynamically by category and author. Each article displays its historical like counts, providing insight into its popularity over time. The application is built with a focus on modern Rails practices, using Hotwire for a dynamic frontend experience and a robust RSpec test suite.

## Features Implemented

* **User Authentication:** Secure sign-up, log-in, and log-out functionality powered by Devise.
* **Article Display:** Browse a collection of news articles, each with a title, publication date, category, author, and detailed body content.
* **Dynamic Filtering:**
    * Filter articles by **category** and **author** using intuitive dropdowns.
    * Author dropdowns dynamically update based on the selected category.
    * Automatic selection of the first relevant author in the dropdown when a category is chosen, enhancing user experience.
* **Like Count Visualization:** View historical like counts for each article, providing a trend of its engagement.
* **Efficient Pagination:** Utilizes the `pagy` gem for fast and scalable pagination of article listings.
* **Data Import Rake Task:** A custom Rake task (`import:news_articles`) is available to efficiently import articles and their associated historical like data from CSV and HTML files.
* **Modern Frontend:** Powered by **Hotwire** (Turbo and Stimulus) for a responsive and dynamic user experience without complex JavaScript frameworks.
* **Comprehensive Testing:** A robust test suite developed with **RSpec**, **FactoryBot**, and **Shoulda Matchers** ensures reliability and maintainability.
* **Code Quality:** Enforces consistent code style and best practices using **RuboCop**.

## Technologies Used

* Ruby (3.2.2)
* Ruby on Rails (7.1.x)
* **Devise** for authentication
* **Hotwire**:
    * **Turbo** for fast page navigation and dynamic updates.
    * **Stimulus** for modest JavaScript behavior (e.g., dynamic filtering).
* **Pagy** for efficient pagination
* **SQLite3** as the development database
* **RSpec** for testing
* **SimpleCov** for code coverage
* **RuboCop** for code quality

## Getting Started

### Prerequisites

* Ruby (>= 3.2.2)
* Rails (>= 7.1.5.1)
* Bundler (`gem install bundler`)
* Node.js (for JavaScript build tooling, typically required by Rails 7 setup)

### Setup

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url> # Replace with your actual repository URL
    cd news_app
    ```

2.  **Install Ruby dependencies:**
    ```bash
    bundle install
    ```

3.  **Prepare the database:**
    ```bash
    rails db:create
    rails db:migrate
    ```

4.  **Import initial data (Crucial for populating articles):**
    This application requires data to be imported from CSV and HTML files. Ensure you have your `news_articles.csv` file and corresponding HTML body files (e.g., `article_title.html`) in the `data/` directory at the root of your project.
    ```bash
    bundle exec rake import:news_articles
    ```
    *(Note: This task will look for `data/news_articles.csv` and use the `title` column to find corresponding HTML files in the `data/` directory.)*

5.  **Start the Rails server:**
    ```bash
    rails s
    ```

6.  Open your browser and navigate to `http://localhost:3000`.

### Running Tests

To execute the full test suite:

```bash
bundle exec rspec