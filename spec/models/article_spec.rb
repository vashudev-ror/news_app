require 'rails_helper'

RSpec.describe Article, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:like_counts).dependent(:destroy) }
  end

  describe 'validations' do
    subject { create(:article) } # required for uniqueness

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title) }
    it { is_expected.to validate_presence_of(:publication_date) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:body) }
  end

  describe 'scopes' do
    let!(:tech_article) { create(:article, category: 'Tech', author: 'Alice') }
    let!(:sports_article) { create(:article, category: 'Sports', author: 'Bob') }

    it 'filters by category' do
      expect(described_class.by_category('Tech')).to include(tech_article)
      expect(described_class.by_category('Tech')).not_to include(sports_article)
    end

    it 'filters by author' do
      expect(described_class.by_author('Bob')).to include(sports_article)
      expect(described_class.by_author('Bob')).not_to include(tech_article)
    end
  end
end
