class GetAllUsers
  def call
    {
        status: 'SUCCESS', data: User.all.map {|user|
      UserSerializer.new(user).as_json
    }
    }
  end
end