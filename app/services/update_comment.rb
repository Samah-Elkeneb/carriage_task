class UpdateComment

  def initialize(params)
    @id = params[:id]
    @content = params[:content]
    @parent_id = params[:parent_id]
    @commentable_id = params[:commentable_id]
    @commentable_type = params[:commentable_type]
  end

  def call
    comment = Comment.find(@id)
    return {status: 'FAILURE', data: {message: 'Not Authorized'}} unless authorized_user?(comment)
    comment.assign_attributes({content: @content})
    comment.save ? {status: 'SUCCESS', data: CommentSerializer.new(comment)} : {status: 'FAILURE', data: comment.errors}
  end

  private

  def authorized_user?(comment)
    comment.creator_id == User.current_user.id || (User.current_user.admin? && comment.commentable.list.creator.id == User.current_user.id)
  end
end