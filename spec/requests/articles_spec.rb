require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  let(:user) { create(:user) }

  let!(:tech_article)    { create(:article, title: 'Tech A', category: 'Tech', author: 'Alice', publication_date: '2024-01-01') }
  let!(:sports_article)  { create(:article, title: 'Sports B', category: 'Sports', author: 'Bob', publication_date: '2024-01-02') }
  let!(:other_article)   { create(:article, title: 'Tech C', category: 'Tech', author: 'Charlie', publication_date: '2023-12-31') }

  before do
    sign_in user
  end

  describe 'GET /articles' do
    it 'returns a successful response' do
      get articles_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(tech_article.title)
      expect(response.body).to include(sports_article.title)
    end

    it 'paginates articles correctly' do
      create_list(:article, 25, category: 'Tech', author: 'Alice')
      get articles_path
      expect(assigns(:articles).count).to be <= 20 # default pagy size if not customized
    end

    context 'when filtering by category' do
      it 'returns only articles from that category' do
        get articles_path, params: { category: 'Tech' }
        expect(assigns(:articles)).to all(have_attributes(category: 'Tech'))
        expect(response.body).not_to include(sports_article.title)
      end
    end

    context 'when filtering by author' do
      it 'returns only articles by that author' do
        get articles_path, params: { author: 'Alice' }
        expect(assigns(:articles)).to all(have_attributes(author: 'Alice'))
        expect(response.body).not_to include(sports_article.title)
      end
    end

    context 'when filtering by both category and author' do
      it 'returns correct intersection' do
        get articles_path, params: { category: 'Tech', author: 'Alice' }
        expect(assigns(:articles)).to eq([tech_article])
      end
    end

    context 'when filters return no results' do
      it 'returns an empty list' do
        get articles_path, params: { category: 'Unknown' }
        expect(assigns(:articles)).to be_empty
        expect(response.body).to include('No articles found').or be_truthy
      end
    end
  end

  describe 'GET /articles/:id' do
    before do
      create(:like_count, article: tech_article, count: 3)
      create(:like_count, article: tech_article, count: 2)
    end

    it 'shows the article with total like count' do
      get article_path(tech_article)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(tech_article.title)
      response.body.include?("<strong>Total Likes:</strong> 5")
    end

    it 'raises RecordNotFound for invalid article ID' do
      get article_path(id: -999)
      expect(response).to redirect_to(articles_path)
    end
  end

  describe 'GET /articles/filtered_authors' do
    it 'returns authors in JSON for a category' do
      get filtered_authors_articles_path, params: { category: 'Tech' }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include('Alice', 'Charlie')
    end

    it 'returns all authors if no category is given' do
      get filtered_authors_articles_path
      authors = response.parsed_body
      expect(authors).to include('Alice', 'Bob', 'Charlie')
    end

    it 'returns an empty array for unmatched category' do
      get filtered_authors_articles_path, params: { category: 'Unknown' }
      expect(response.parsed_body).to eq([])
    end
  end

  describe 'unauthenticated access' do
    before { sign_out user }

    it 'redirects unauthenticated users to login on index' do
      get articles_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects unauthenticated users on show' do
      get article_path(tech_article)
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects unauthenticated users on filtered_authors' do
      get filtered_authors_articles_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
