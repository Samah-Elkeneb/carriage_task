class UsersController < ApplicationController
  @@allowed_params = [:id, :user_name, :user_type, :password, :email]

  def all_users
    get_response(GetAllUsers)
  end

  def sign_up
    get_response(CreateUser, user_params)
  end

  def login
    get_response(Login, user_params)
  end

  private
  def user_params
    params.permit(*@@allowed_params).merge(model: User)
  end

end