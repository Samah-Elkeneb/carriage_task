class CommentsController < ApplicationController
  before_action :authenticate_user, :authorized_user?
  @@allowed_params = [:id, :content, :parent_id, :commentable_id, :commentable_type, :page_num]

  def all_comments
    get_response(GetAllComments, comment_params)
  end

  def show
    get_response(GetCommentById, comment_params)
  end

  def create
    get_response(CreateComment, comment_params)
  end

  def update
    get_response(UpdateComment, comment_params)
  end

  def delete
    get_response(Delete, comment_params)
  end

  private
  def comment_params
    params.permit(*@@allowed_params).merge(model: Comment)
  end
end