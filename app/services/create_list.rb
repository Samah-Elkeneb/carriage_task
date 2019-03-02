class CreateList

	def initialize(params)
    @title = params[:title]
  end

  def call
    list = List.new(title: @title)
    list.save ? {status: 'SUCCESS', data: ListSerializer.new(list)} : {status: 'FAILURE', data: list.errors}
  end

end