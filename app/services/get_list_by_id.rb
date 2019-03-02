class GetListById

  def initialize(params)
    @id = params[:id]
  end

  def call
    lists  = User.current_user.admin? ?  List : List.member_lists
    list = lists.find(@id)
   {status: 'SUCCESS', data: ListSerializer.new(list)}
  end
end