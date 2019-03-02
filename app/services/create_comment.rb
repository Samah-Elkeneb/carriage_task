class CreateComment

  def initialize(params)
    @content = params[:content]
    @parent_id = params[:parent_id]
    @commentable_id = params[:commentable_id]
    @commentable_type = params[:commentable_type]
  end

  def call
    return {status: 'FAILURE', data: {message: 'Not Authorized'}} unless authorized_user?
    comment = Comment.new(content: @content, parent_id: @parent_id, commentable_id: @commentable_id, commentable_type: @commentable_type)
    comment.save ? {status: 'SUCCESS', data: CommentSerializer.new(comment)} : {status: 'FAILURE', data: comment.errors}
  end

  private

  def authorized_user?
    member_case =  List.member_lists.pluck(:id).include?(Card.where(id: @commentable_id).first.list_id)
    User.current_user.admin? ||  member_case
  end
end