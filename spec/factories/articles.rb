FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Sample Title #{n}" }
    publication_date { Time.zone.today }
    category { "Tech" }
    author { "Author #{rand(100)}" }
    body { "Sample article body" }
  end
end
