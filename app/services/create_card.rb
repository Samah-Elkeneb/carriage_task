class CreateCard

  def initialize(params)
    @title = params[:title]
    @description = params[:description]
    @list_id = params[:list_id].to_i
  end

  def call
    return {status: 'FAILURE', data: {message: 'Not Authorized'}} unless authorized_user?
    card = prepare_card
    card.save ? {status: 'SUCCESS', data: ShowCardSerializer.new(card)} : {status: 'FAILURE', data: card.errors}
  end

  private

  def prepare_card
    Card.new({title: @title, description: @description, list_id: @list_id})
  end

  def authorized_user?
    User.current_user.admin? || List.member_lists.pluck(:id).include?(@list_id)
  end

end