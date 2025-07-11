class Article < ApplicationRecord
  has_many :like_counts, dependent: :destroy

  validates :title, presence: true, uniqueness: true
  validates :publication_date, :category, :author, :body, presence: true
  scope :by_category, ->(category) { where(category: category) }
  scope :by_author,   ->(author)   { where(author: author) }
end
