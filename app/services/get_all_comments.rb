class GetAllComments

  def initialize(params)
    @parent_id = params[:parent_id]
    @commentable_id = params[:commentable_id]
    @commentable_type = params[:commentable_type]
    @page_num = params[:page_num]
  end

  def call
    all_comments = User.current_user.admin? ? Comment : Comment.joins("INNER JOIN cards ON cards.id == comments.commentable_id AND comments.commentable_type = 'Card' INNER JOIN lists ON lists.id = cards.list_id").where("lists.id in (?)", User.current_user.list_ids.join(','))
    page_num = @page_num.to_i <= 0 ? 1 : @page_num.to_i
    all_comments = all_comments.limit(Comment::LIMIT).offset((page_num - 1) * Comment::LIMIT)
    comments = @parent_id ? all_comments.where(parent_id: @parent_id)
                   : all_comments.where(commentable_id: @commentable_id, commentable_type: @commentable_type)
    {
        status: 'SUCCESS', data: comments.includes(:creator).map {|comment|
      CommentSerializer.new(comment)
    }
    }
  end
end
