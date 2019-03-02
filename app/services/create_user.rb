class CreateUser

  def initialize(params)
    @email = params[:email]
    @password = params[:password]
    @user_name = params[:user_name]
    @user_type = params[:user_type]
  end

  def call
    user = User.new(user_name: @user_name, user_type: @user_type, password: @password, password_confirmation: @password, email: @email)
    user.save ? {status: 'SUCCESS', data: UserSerializer.new(user)} : {status: 'FAILURE', data: user.errors}
  end

end