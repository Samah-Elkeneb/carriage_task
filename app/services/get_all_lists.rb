class GetAllLists
	def call
		lists = User.current_user.admin? ?  List.all : List.member_lists
		{
				status: 'SUCCESS', data: lists.includes([:members, :cards, :creator]).map {|list|
        ListSerializer.new(list)
      }
		}
	end
end