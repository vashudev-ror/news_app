require 'rails_helper'

RSpec.describe LikeCount, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:article) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_numericality_of(:count).only_integer.is_greater_than_or_equal_to(0) }
  end
end
