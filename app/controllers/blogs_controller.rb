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

  def set_blog_for_show
    base_scope = Blog.where(secret: false)
    scope = if user_signed_in?
              base_scope.or(Blog.where(user_id: current_user.id))
            else
              base_scope
            end
    @blog = scope.find(params[:id])
  end

  def set_blog_for_modify
    @blog = Blog.find(params[:id])
  end

  def blog_params
    allowed = %i[title content secret]
    allowed << :random_eyecatch if current_user.premium?
    params.require(:blog).permit(*allowed)
  end
end
