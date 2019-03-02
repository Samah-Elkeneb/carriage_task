class GetAllCards
	def call
		{
				status: 'SUCCESS', data: all_cards.includes(:creator, :comments).map {|card|
        CardSerializer.new(card)
      }
		}
	end

  private
  def all_cards
		cards = User.current_user.admin? ?  Card : Card.where(list_id: List.member_lists.pluck(:id))
		cards.left_joins(:comments).where(comments: {parent_id: nil}).group(:id).order('COUNT (comments.id) DESC')
	end
end