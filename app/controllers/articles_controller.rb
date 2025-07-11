class ArticlesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_article, only: [:show]

  def index
    articles_scope = Article.order(publication_date: :desc)

    @categories = Article.categories_list.unshift("All Categories")

    articles_scope = articles_scope.by_category(params[:category]) if params[:category].present? && params[:category] != "All Categories"

    @authors = articles_scope.distinct.pluck(:author).sort.unshift("All Authors")

    articles_scope = articles_scope.by_author(params[:author]) if params[:author].present? && params[:author] != "All Authors"

    @pagy, @articles = pagy(articles_scope)
    respond_to do |format|
      format.html
      format.json do
        render json: @articles.as_json(
          only: [:title, :publication_date, :category, :author], # direct attributes
          methods: [:total_likes, :body_excerpt_json] # custom methods
        )
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json do
        render json: @article.as_json(
          only: [:title, :publication_date, :category, :author],
          methods: [:total_likes, :full_body_json]
        )
      end
    end
  end

  def filtered_authors
    authors_scope = Article.all
    authors_scope = authors_scope.by_category(params[:category]) if params[:category].present? && params[:category] != "All Categories"
    filtered_authors_list = authors_scope.distinct.pluck(:author).sort
    render json: filtered_authors_list
  end

  private

  def set_article
    @article = Article.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to articles_path, alert: 'Article not found.' }
      format.json { render json: { error: 'Article not found' }, status: :not_found }
    end
  end
end
