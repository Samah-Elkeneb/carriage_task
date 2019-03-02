class Login

  def initialize(params)
    @email = params[:email]
    @password = params[:password]
  end

  def call
    user = User.find_by_email(@email)
    user && user.authenticate(@password) ? {status: 'SUCCESS', data: UserWithTokenSerializer.new(user)}:{status: 'FAILURE', data: {message: 'Invalid User'}}
  end
end