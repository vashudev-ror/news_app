class Article < ApplicationRecord
  has_many :like_counts, dependent: :destroy

  validates :title, presence: true, uniqueness: true
  validates :body, presence: true
  validates :author, presence: true
  validates :publication_date, presence: true
  validates :category, presence: true

  scope :by_category, ->(category) { where(category: category) }
  scope :by_author,   ->(author)   { where(author: author) }

  include ActionView::Helpers::SanitizeHelper

  def total_likes
    like_counts.sum(:count)
  end

  def body_excerpt(length = 200, omission = '...')
    stripped_body = strip_tags(body)
    stripped_body.truncate(length, omission: omission)
  end

  def body_excerpt_json
    body_excerpt(200, '...')
  end

  def full_body_json
    body
  end

  def self.categories_list
    Rails.cache.fetch("article_categories_list", expires_in: 1.hour) do
      distinct.pluck(:category).sort
    end
  end

  def self.authors_list
    Rails.cache.fetch("article_authors_list", expires_in: 1.hour) do
      distinct.pluck(:author).sort
    end
  end
end
