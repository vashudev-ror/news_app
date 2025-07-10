class Article < ApplicationRecord
  has_many :like_counts, dependent: :destroy

  validates :title, presence: true, uniqueness: true
  validates :publication_date, :category, :author, :body, presence: true
end
