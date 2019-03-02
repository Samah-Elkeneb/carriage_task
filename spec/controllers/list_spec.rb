require 'rails_helper'

describe ListsController do

  before :each do
    @admin_user = User.create!({user_name: "admin user", user_type: "admin", password: "123123", email: "admin@gmail.com"})
    @member_user = User.create!({user_name: "member user", user_type: "member", password: "123123", email: "member@gmail.com"})
  end

  context 'empty database' do
    it 'test all lists end point with admin' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "all_lists"})
      params = {remember_token: @admin_user.remember_token}
      response = JSON.parse(get(:all_lists, params).body)
      expect(response['data']).to eq([])
    end

    it 'test all lists end point with member' do
      Rule.create({user_type: 1, controller_name: "lists", action_name: "all_lists"})
      params = {remember_token: @member_user.remember_token}
      response = JSON.parse(get(:all_lists, params).body)
      expect(response['data']).to eq([])
    end
  end
  context 'database with data' do
    before :each do
      User.current_user = @admin_user
      @list_without_members = List.create!({title: 'list title', creator: @admin_user})
      @list_with_members = List.create!({title: 'list title', creator: @admin_user, member_ids: [@member_user.id]})
    end
    it 'test all lists end point with admin' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "all_lists"})
      params = {remember_token: @admin_user.remember_token}
      response = JSON.parse(get(:all_lists, params).body)
      expect([response['data'][0]["id"]]).to eq([@list_without_members.id])
      expect(response['data'].size).to eq(2)
    end

    it 'test all lists end point with member' do
      Rule.create({user_type: 1, controller_name: "lists", action_name: "all_lists"})
      params = {remember_token: @member_user.remember_token}
      response = JSON.parse(get(:all_lists, params).body)
      expect([response['data'][0]["id"]]).to eq([@list_with_members.id])
      expect(response['data'].size).to eq(1)
    end

    it 'test show list end point with admin' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "show"})
      params = ({id: @list_with_members.id, remember_token: @admin_user.remember_token})
      response = JSON.parse(get(:show, params).body)
      expect(response['data']['id']).to eq(@list_with_members.id)
    end

    it 'test show list end point with valid member' do
      Rule.create({user_type: 1, controller_name: "lists", action_name: "show"})
      params = ({id: @list_with_members.id, remember_token: @member_user.remember_token})
      response = JSON.parse(get(:show, params).body)
      expect(response['data']['id']).to eq(@list_with_members.id)
    end

    it 'test show list end point with invalid member' do
      Rule.create({user_type: 1, controller_name: "lists", action_name: "show"})
      params = ({id: @list_without_members.id, remember_token: @member_user.remember_token})
      response = JSON.parse(get(:show, params).body)
      expect(response['data']['message']).to eq('Record Not Found')
    end

    it 'test create end point with admin' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "create"})
      params = ({title: "list title", remember_token: @admin_user.remember_token})
      lists_count = List.count
      response = JSON.parse(post(:create, params).body)
      expect(response['data']['title']).to eq('list title')
      expect(List.count).to eq(lists_count + 1)
    end

    it 'test create end point with admin with invalid data' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "create"})
      params = {remember_token: @admin_user.remember_token}
      lists_count = List.count
      response = JSON.parse(post(:create, params).body)
      expect(response['data']['title']).to eq(["can't be blank"])
      expect(List.count).to eq(lists_count)
    end

    it 'test create end point with member' do
      params = ({title: "list title", remember_token: @member_user.remember_token})
      response = JSON.parse(post(:create, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
    end

    it 'test update end point with admin' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "update"})
      params = ({id: @list_with_members.id, title: "new list title", remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['id']).to eq(@list_with_members.id)
      expect(response['data']['title']).to eq('new list title')
    end

    it 'test update end point with admin with invalid data' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "update"})
      params = ({id: @list_with_members.id, remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['title']).to eq(["can't be blank"])
    end

    it 'test update end point with admin with another admin list' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "update"})
      user = User.create!({user_name: "user", user_type: "admin", password: "123123", email: "user@gmail.com"})
      list = List.create!({title: 'list title', creator: user})
      params = ({id: list.id, remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['message']).to eq("Record Not Found")
    end

    it 'test update end point with member' do
      params = ({id: @list_with_members.id, title: "new list title", remember_token: @member_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
    end

    it 'test destroy end point with admin' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "delete"})
      params = ({id: @list_with_members.id, remember_token: @admin_user.remember_token})
      lists_count = List.count
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['id']).to eq(@list_with_members.id)
      expect(List.count).to eq(lists_count - 1)
    end

    it 'test destroy end point with admin with invalid id' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "delete"})
      params = ({id: 100, remember_token: @admin_user.remember_token})
      lists_count = List.count
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['message']).to eq('Record Not Found')
      expect(List.count).to eq(lists_count)
    end

    it 'test destroy end point with admin with another admin list' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "delete"})
      user = User.create!({user_name: "user", user_type: "admin", password: "123123", email: "user@gmail.com"})
      list = List.create!({title: 'list title', creator: user})
      params = ({id: list.id, remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
    end

    it 'test destroy end point with member' do
      params = ({id: @list_with_members.id, remember_token: @member_user.remember_token})
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
    end

    it 'test update members end point with admin' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "update_members"})
      params = ({id: @list_without_members.id, member_ids: [@member_user.id], remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:update_members, params).body)
      expect(response['data']['id']).to eq(@list_without_members.id)
      expect(response['data']['members'][0]['id']).to eq(@member_user.id)
      expect(response['data']['members'].size).to eq(1)
    end

    it 'test update members end point with admin with another admin list' do
      Rule.create({user_type: 0, controller_name: "lists", action_name: "update_members"})
      user = User.create!({user_name: "user", user_type: "admin", password: "123123", email: "user@gmail.com"})
      list = List.create!({title: 'list title', creator: user})
      params = ({id: list.id, remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:update_members, params).body)
      expect(response['data']['message']).to eq("Record Not Found")
    end

    it 'test update members end point with member' do
      params = ({id: @list_without_members.id, member_ids: [@member_user.id], remember_token: @member_user.remember_token})
      response = JSON.parse(post(:update_members, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
    end
  end
end