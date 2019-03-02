require 'rails_helper'

describe CardsController do

  before :each do
    @user = User.create!({user_name: "user", user_type: "admin", password: "123123", email: "user@gmail.com"})
    @admin_user = User.create!({user_name: "admin user", user_type: "admin", password: "123123", email: "admin@gmail.com"})
    @member_user = User.create!({user_name: "member user", user_type: "member", password: "123123", email: "member@gmail.com"})
  end

  context 'empty database' do
    it 'test all cards end point with admin' do
      Rule.create({user_type: 0, controller_name: "cards", action_name: "all_cards"})
      params = {remember_token: @admin_user.remember_token}
      response = JSON.parse(get(:all_cards, params).body)
      expect(response['data']).to eq([])
    end

    it 'test all cards end point with member' do
      Rule.create({user_type: 1, controller_name: "cards", action_name: "all_cards"})
      params = {remember_token: @member_user.remember_token}
      response = JSON.parse(get(:all_cards, params).body)
      expect(response['data']).to eq([])
    end
  end

  context 'database with data' do
    before :each do
      User.current_user = @admin_user
      @list_by_user = List.create!({title: 'list title', creator: @user})
      @list_by_admin_user_with_member = List.create!({title: 'list title', creator: @admin_user, member_ids: [@member_user.id]})
      @admin_card1 = Card.create!({title: 'card title 1', list_id: @list_by_user.id, creator: @admin_user})
      @admin_card2 = Card.create!({title: 'card title 2', list_id: @list_by_admin_user_with_member.id, creator: @admin_user})
      @member_card1 = Card.create!({title: 'card title 1', list_id: @list_by_admin_user_with_member.id, creator: @member_user})
      @member_card2 = Card.create!({title: 'card title 2', list_id: @list_by_admin_user_with_member.id, creator: @member_user})
      @card_with_own_list_for_all = Card.create!({title: 'card title', list_id: @list_by_admin_user_with_member.id, creator: @user})
      @user_card = Card.create!({title: 'card title 1', list_id: @list_by_user.id, creator: @user})
    end

    it 'test all cards end point with admin' do
      Rule.create({user_type: 0, controller_name: "cards", action_name: "all_cards"})
      params = {remember_token: @admin_user.remember_token}
      response = JSON.parse(get(:all_cards, params).body)
      expect(response['data'].size).to eq(6)
    end

    it 'test all cards end point with member' do
      Rule.create({user_type: 1, controller_name: "cards", action_name: "all_cards"})
      params = {remember_token: @member_user.remember_token}
      response = JSON.parse(get(:all_cards, params).body)
      expect(response['data'].size).to eq(4)
      expect(response['data'][0]['list_id']).to eq(@list_by_admin_user_with_member.id)
      expect(response['data'][1]['list_id']).to eq(@list_by_admin_user_with_member.id)
      expect(response['data'][2]['list_id']).to eq(@list_by_admin_user_with_member.id)
      expect(response['data'][2]['list_id']).to eq(@list_by_admin_user_with_member.id)
    end

    it 'test show card end point with admin' do
      Rule.create({user_type: 0, controller_name: "cards", action_name: "show"})
      params = ({id: @admin_card1.id, remember_token: @admin_user.remember_token})
      response = JSON.parse(get(:show, params).body)
      expect(response['data']['id']).to eq(@admin_card1.id)
    end

    it 'test show card end point with member with valid data' do
      Rule.create({user_type: 1, controller_name: "cards", action_name: "show"})
      params = ({id: @member_card1.id, remember_token: @member_user.remember_token})
      response = JSON.parse(get(:show, params).body)
      expect(response['data']['id']).to eq(@member_card1.id)
    end

    it 'test show card end point with member with invalid data' do
      Rule.create({user_type: 1, controller_name: "cards", action_name: "show"})
      params = ({id: @admin_card1.id, remember_token: @member_user.remember_token})
      response = JSON.parse(get(:show, params).body)
      expect(response['data']['message']).to eq("Record Not Found")
    end

    it 'test create end point with admin' do
      Rule.create({user_type: 0, controller_name: "cards", action_name: "create"})
      params = ({title: "card title", list_id: @list_by_user.id, remember_token: @admin_user.remember_token})
      cards_count = Card.count
      response = JSON.parse(post(:create, params).body)
      expect(response['data']['list_id']).to eq(@list_by_user.id)
      expect(Card.count).to eq(cards_count + 1)
    end

    it 'test create end point with member on his list' do
      Rule.create({user_type: 1, controller_name: "cards", action_name: "create"})
      params = ({title: "card title", list_id: @list_by_admin_user_with_member.id, remember_token: @member_user.remember_token})
      cards_count = Card.count
      response = JSON.parse(post(:create, params).body)
      expect(response['data']['list_id']).to eq(@list_by_admin_user_with_member.id)
      expect(Card.count).to eq(cards_count + 1)
    end

    it 'test create end point with member on another user list' do
      Rule.create({user_type: 1, controller_name: "cards", action_name: "create"})
      params = ({title: "card title", list_id: @list_by_user.id, remember_token: @member_user.remember_token})
      cards_count = Card.count
      response = JSON.parse(post(:create, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
      expect(Card.count).to eq(cards_count)
    end

    it 'test update end point with admin' do
      Rule.create({user_type: 0, controller_name: "cards", action_name: "update"})
      params = ({id: @admin_card1.id, title: "new card title", list_id: @list_by_user.id, remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['id']).to eq(@admin_card1.id)
      expect(response['data']['title']).to eq('new card title')
    end

    it 'test update end point with admin with invalid data' do
      Rule.create({user_type: 0, controller_name: "cards", action_name: "update"})
      params = ({id: @admin_card1.id, title: "new card title", remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['list']).to eq(["must exist"])
    end

    it 'test update end point with not authorized admin' do
      Rule.create({user_type: 0, controller_name: "cards", action_name: "update"})
      params = ({id: @user_card.id, title: "new card title", list_id: @list_by_user.id, remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
    end

    it 'test update end point with member with invalid data' do
      Rule.create({user_type: 1, controller_name: "cards", action_name: "update"})
      params = ({id: @member_card1.id, title: "new card title", remember_token: @member_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['list']).to eq(["must exist"])
    end

    it 'test update end point with member' do
      Rule.create({user_type: 1, controller_name: "cards", action_name: "update"})
      params = ({id: @member_card1.id, title: "new card title", list_id: @list_by_admin_user_with_member.id, remember_token: @member_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['id']).to eq(@member_card1.id)
      expect(response['data']['title']).to eq('new card title')
    end

    it 'test update end point with not authorized member' do
      Rule.create({user_type: 1, controller_name: "cards", action_name: "update"})
      params = ({id: @card_with_own_list_for_all.id, title: "new card title", list_id: @list_by_admin_user_with_member.id, remember_token: @member_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
    end

    it 'test destroy end point with admin with own card' do
      Rule.create({user_type: 0, controller_name: "cards", action_name: "delete"})
      params = ({id: @admin_card1.id, remember_token: @admin_user.remember_token})
      cards_count = Card.count
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['id']).to eq(@admin_card1.id)
      expect(Card.count).to eq(cards_count - 1)
    end

    it 'test destroy end point with admin with card on his list' do
      Rule.create({user_type: 0, controller_name: "cards", action_name: "delete"})
      params = ({id: @member_card1.id, remember_token: @admin_user.remember_token})
      cards_count = Card.count
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['id']).to eq(@member_card1.id)
      expect(Card.count).to eq(cards_count - 1)
    end

    it 'test destroy end point with not authorized admin' do
      Rule.create({user_type: 0, controller_name: "cards", action_name: "delete"})
      params = ({id: @user_card.id, remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
    end

    it 'test destroy end point with member' do
      Rule.create({user_type: 1, controller_name: "cards", action_name: "delete"})
      params = ({id: @member_card1.id, remember_token: @member_user.remember_token})
      cards_count = Card.count
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['id']).to eq(@member_card1.id)
      expect(Card.count).to eq(cards_count - 1)
    end

    it 'test destroy end point with not authorized member' do
      Rule.create({user_type: 1, controller_name: "cards", action_name: "delete"})
      params = ({id: @card_with_own_list_for_all.id, remember_token: @member_user.remember_token})
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
    end

  end

end