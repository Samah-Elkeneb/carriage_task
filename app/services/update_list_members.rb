class UpdateListMembers

	def initialize(params)
		@id = params[:id]
		@member_ids = params[:member_ids]
  	end

	def call
    	list = List.where(creator_id: User.current_user.id).find(@id)
			list.member_ids = @member_ids
			list.save ? {status: 'SUCCESS', data: ListSerializer.new(list)} : {status: 'FAILURE', data: list.errors}
  	end

end