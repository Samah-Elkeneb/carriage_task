class Delete

  def initialize(params)
    @id = params[:id]
    @model = params[:model]
  end

  def call
    obj = @model.find(@id)
    return {status: 'FAILURE', data: {message: 'Not Authorized'}} unless authorized_user?(obj)
    obj.destroy ? {status: 'SUCCESS', data: obj} : {status: 'FAILURE', data: obj.errors}
  end

  private

  def authorized_user?(obj)
    case @model.to_s
    when "List"
      User.current_user.admin? && obj.creator.id == User.current_user.id
    when "Card"
      obj.creator_id == User.current_user.id || (User.current_user.admin? && obj.list.creator_id == User.current_user.id)
    when "Comment"
      obj.creator_id == User.current_user.id || (User.current_user.admin? && obj.commentable.list.creator.id == User.current_user.id)
    end
  end

end