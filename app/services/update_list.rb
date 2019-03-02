class UpdateList

	def initialize(params)
		@id = params[:id]
    @title = params[:title]
  end

	def call
    list = List.where(creator_id: User.current_user.id).find(@id)
    list.assign_attributes({title: @title})
    list.save ? {status: 'SUCCESS', data: ListSerializer.new(list)} : {status: 'FAILURE', data: list.errors}
  end

end