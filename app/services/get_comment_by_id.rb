class GetCommentById

  def initialize(params)
    @id = params[:id]
  end

  def call
    all_comments = User.current_user.admin? ? Comment : Comment.joins("INNER JOIN cards ON cards.id == comments.commentable_id AND comments.commentable_type = 'Card' INNER JOIN lists ON lists.id = cards.list_id").where("lists.id in (?)", User.current_user.list_ids.join(','))
    comment = all_comments.find(@id)
    replies = Comment.where(parent_id: comment.id)
    {
        status: 'SUCCESS', data: [comment, replies].flatten.map {|cmnt| CommentSerializer.new(cmnt)}
    }
  end
end