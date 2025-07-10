class LikeCount < ApplicationRecord
  belongs_to :article

  validates :date, presence: true
  validates :count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
