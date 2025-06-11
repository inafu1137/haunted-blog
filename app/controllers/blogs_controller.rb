# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog_for_show, only: [:show]
  before_action :set_blog_for_modify, only: %i[edit update destroy]
  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog_for_show
    published_blogs = Blog.published
    accessible_blogs = if user_signed_in?
                         published_blogs.or(Blog.where(user: current_user))
                       else
                         published_blogs
                       end
    @blog = accessible_blogs.find(params[:id])
  end

  def set_blog_for_modify
    @blog = current_user.blogs.find(params[:id])
  end

  def blog_params
    allowed = %i[title content secret]
    allowed << :random_eyecatch if current_user.premium?
    params.require(:blog).permit(*allowed)
  end
end
