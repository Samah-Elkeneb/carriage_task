class UpdateCard

  def initialize(params)
    @id = params[:id]
    @title = params[:title]
    @description = params[:description]
    @list_id = params[:list_id]
  end

  def call
    card = Card.find(@id)
    return {status: 'FAILURE', data: {message: 'Not Authorized'}} unless authorized_user?(card)
    card.assign_attributes({title: @title, description: @description, list_id: @list_id})
    card.save ? {status: 'SUCCESS', data: ShowCardSerializer.new(card)} : {status: 'FAILURE', data: card.errors}
  end

  private

  def authorized_user?(card)
    card.creator_id == User.current_user.id || (User.current_user.admin? && card.list.creator_id == User.current_user.id)
  end

end