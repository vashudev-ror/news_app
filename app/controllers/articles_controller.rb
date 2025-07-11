# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_user!
  before_action :set_article, only: [:show]

  def index
    @categories = Article.distinct.pluck(:category)

    articles = Article.order(publication_date: :desc)
    articles = articles.by_category(params[:category]) if params[:category].present?

    @authors = articles.distinct.pluck(:author)
    articles = articles.by_author(params[:author]) if params[:author].present?

    @pagy, @articles = pagy(articles)
  end

  def show
    @total_likes = @article.like_counts.sum(:count)
  end

  def filtered_authors
    authors_scope = Article.all # Start with all articles for this specific query
    authors_scope = authors_scope.by_category(params[:category]) if params[:category].present?
    render json: authors_scope.distinct.pluck(:author)
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end
end
