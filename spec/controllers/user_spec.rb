require 'rails_helper'

describe UsersController do
  it 'test all users end point' do
    response = JSON.parse(get(:all_users).body)
    expect(response['data']).to eq([])
  end
  it 'test all users end point with data' do
    user = User.create!({user_name: "user", user_type: "admin", password: "123123", email: "user@gmail.com"})
    response = JSON.parse(get(:all_users).body)
    expect(response['data'][0]["id"]).to eq(user.id)
    expect(response['data'].size).to eq(1)
  end
  it 'test sign_up end point' do
    params = ({user_name: "user", user_type: "admin", password: "123123", email: "user@gmail.com"})
    users_count = User.count
    response = JSON.parse(post(:sign_up, params).body)
    expect(response['data']['email']).to eq("user@gmail.com")
    expect(User.count).to eq(users_count + 1)
  end

  it 'test sign_up end point with invalid data' do
    users_count = User.count
    response = JSON.parse(post(:sign_up).body)
    expect(response['data']['email']).to eq(["can't be blank", "is invalid"])
    expect(response['data']['user_name']).to eq(["can't be blank"])
    expect(response['data']['user_type']).to eq(["can't be blank"])
    expect(response['data']['password']).to eq(["can't be blank"])
    expect(User.count).to eq(users_count)
  end

  it 'test sign_up end point with duplicated email' do
    User.create!({user_name: "user", user_type: "admin", password: "123123", email: "user@gmail.com"})
    params = ({user_name: "user", user_type: "admin", password: "123123", email: "user@gmail.com"})
    users_count = User.count
    response = JSON.parse(post(:sign_up, params).body)
    expect(response['data']['email']).to eq(["has already been taken"])
    expect(User.count).to eq(users_count)
  end

  it 'test login end point' do
    user = User.create!({user_name: "user", user_type: "admin", password: "123123", email: "user@gmail.com"})
    params = ({email: user.email, password: "123123"})
    response = JSON.parse(post(:login, params).body)
    expect(response['data']['email']).to eq(user.email)
  end

  it 'test login end point with invalid data' do
    user = User.create!({user_name: "user", user_type: "admin", password: "123123", email: "user@gmail.com"})
    params = ({email: user.email, password: "1231233"})
    response = JSON.parse(post(:login, params).body)
    expect(response['data']['message']).to eq('Invalid User')
  end
end