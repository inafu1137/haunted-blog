# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    @blog = Blog.find(params[:id])
    raise ActiveRecord::RecordNotFound if @blog.secret? && (!user_signed_in? || current_user != @blog.user)
  end

  def new
    @blog = Blog.new
  end

  def edit
    @blog = Blog.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @blog.user == current_user
  end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @blog = current_user.blogs.find(params[:id])
    params[:blog][:random_eyecatch] = false if !current_user.premium? && params[:blog] && params[:blog][:random_eyecatch]
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog = current_user.blogs.find(params[:id])
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end
end
