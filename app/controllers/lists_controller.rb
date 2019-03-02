class ListsController < ApplicationController

  before_action :authenticate_user, :authorized_user?
  @@allowed_params = [:id, :title, member_ids: []]

  def all_lists
    get_response(GetAllLists)
  end

  def show
    get_response(GetListById, list_params)
  end

  def create
    get_response(CreateList, list_params)
  end

  def update
    get_response(UpdateList, list_params)
  end

  def delete
    get_response(Delete, list_params)
  end

  def update_members
    get_response(UpdateListMembers, list_params)
  end

  private
  def list_params
    params.permit(*@@allowed_params).merge(model: List)
  end

end