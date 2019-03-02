class GetCardById

  def initialize(params)
    @id = params[:id]
  end

  def call
    {status: 'SUCCESS', data: ShowCardSerializer.new(card)}
  end

  private

  def card
    cards = User.current_user.admin? ? Card : Card.where(list_id: List.member_lists.pluck(:id))
    cards.find(@id)
  end
end