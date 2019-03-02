require 'rails_helper'

describe CommentsController do
  before :each do
    @user = User.create!({user_name: "user", user_type: "admin", password: "123123", email: "user@gmail.com"})
    @admin_user = User.create!({user_name: "admin user", user_type: "admin", password: "123123", email: "admin@gmail.com"})
    @member_user = User.create!({user_name: "member user", user_type: "member", password: "123123", email: "member@gmail.com"})
  end

  context 'empty database' do
    it 'test all comments end point with admin' do
      Rule.create({user_type: 0, controller_name: "comments", action_name: "all_comments"})
      params = {remember_token: @admin_user.remember_token}
      response = JSON.parse(get(:all_comments, params).body)
      expect(response['data']).to eq([])
    end

    it 'test all cards end point with member' do
      Rule.create({user_type: 1, controller_name: "comments", action_name: "all_comments"})
      params = {remember_token: @member_user.remember_token}
      response = JSON.parse(get(:all_comments, params).body)
      expect(response['data']).to eq([])
    end
  end

  context 'database with data' do
    before :each do
      User.current_user = @admin_user
      @list_by_user = List.create!({title: 'list title', creator: @user})
      @list_by_admin_user_with_member = List.create!({title: 'list title', creator: @admin_user, member_ids: [@member_user.id]})
      @admin_card = Card.create!({title: 'card title 2', list_id: @list_by_user.id, creator: @admin_user})
      @member_card = Card.create!({title: 'card title 1', list_id: @list_by_admin_user_with_member.id, creator: @member_user})
      @user_card = Card.create!({title: 'card title 3', list_id: @list_by_user.id, creator: @user})
      @comment1 = Comment.create!({content: 'comment content', commentable_id: @admin_card.id, commentable_type: "Card", creator: @admin_user})
      @comment2 = Comment.create!({content: 'comment content', commentable_id: @member_card.id, commentable_type: "Card", creator: @member_user})
      @comment3 = Comment.create!({content: 'comment content', commentable_id: @user_card.id, commentable_type: "Card", creator: @user})
      @reply_on_comment1 = Comment.create!({content: 'comment content', parent_id: @comment1.id, commentable_id: @admin_card.id, commentable_type: "Card", creator: @admin_user})
      @reply_on_comment2 = Comment.create!({content: 'comment content', parent_id: @comment2.id, commentable_id: @member_card.id, commentable_type: "Card", creator: @admin_user})
    end

    it 'test all comments end point with admin by commentable' do
      Rule.create({user_type: 0, controller_name: 'comments', action_name: 'all_comments'})
      params = {commentable_id: @member_card, commentable_type: 'Card', remember_token: @admin_user.remember_token}
      response = JSON.parse(get(:all_comments, params).body)
      expect(response['data'].size).to eq(2)
    end

    it 'test all comments end point with admin by parent id' do
      Rule.create({user_type: 0, controller_name: 'comments', action_name: 'all_comments'})
      params = {parent_id: @comment2, remember_token: @admin_user.remember_token}
      response = JSON.parse(get(:all_comments, params).body)
      expect(response['data'].size).to eq(1)
    end

    it 'test all comments end point with member by commentable' do
      Rule.create({user_type: 1, controller_name: 'comments', action_name: 'all_comments'})
      params = {commentable_id: @member_card, commentable_type: 'Card', remember_token: @member_user.remember_token}
      response = JSON.parse(get(:all_comments, params).body)
      expect(response['data'].size).to eq(2)
    end

    it 'test all comments end point with member by parent id' do
      Rule.create({user_type: 1, controller_name: 'comments', action_name: 'all_comments'})
      params = {parent_id: @comment2, remember_token: @member_user.remember_token}
      response = JSON.parse(get(:all_comments, params).body)
      expect(response['data'].size).to eq(1)
    end

    it 'test show end point with admin' do
      Rule.create({user_type: 0, controller_name: "comments", action_name: "show"})
      params = ({id: @comment2.id, remember_token: @admin_user.remember_token})
      response = JSON.parse(get(:show, params).body)
      expect(response['data'][0]['id']).to eq(@comment2.id)
      expect(response['data'].size).to eq(2)
    end

    it 'test show end point with member' do
      Rule.create({user_type: 1, controller_name: "comments", action_name: "show"})
      params = ({id: @comment2.id, remember_token: @member_user.remember_token})
      response = JSON.parse(get(:show, params).body)
      expect(response['data'][0]['id']).to eq(@comment2.id)
      expect(response['data'].size).to eq(2)
    end

    it 'test show end point with not authorized member' do
      Rule.create({user_type: 1, controller_name: "comments", action_name: "show"})
      params = ({id: @comment1.id, remember_token: @member_user.remember_token})
      response = JSON.parse(get(:show, params).body)
      expect(response['data']['message']).to eq('Record Not Found')
    end

    it 'test create end point with admin' do
      Rule.create({user_type: 0, controller_name: "comments", action_name: "create"})
      params = ({content: 'comment content', commentable_id: @admin_card.id, commentable_type: "Card", remember_token: @admin_user.remember_token})
      comments_count = Comment.count
      response = JSON.parse(post(:create, params).body)
      expect(response['data']['content']).to eq('comment content')
      expect(Comment.count).to eq(comments_count + 1)
    end

    it 'test create end point with member' do
      Rule.create({user_type: 1, controller_name: "comments", action_name: "create"})
      params = ({content: 'comment content', commentable_id: @member_card.id, commentable_type: "Card", remember_token: @member_user.remember_token})
      comments_count = Comment.count
      response = JSON.parse(post(:create, params).body)
      expect(response['data']['content']).to eq('comment content')
      expect(Comment.count).to eq(comments_count + 1)
    end

    it 'test create end point with not authorized member' do
      Rule.create({user_type: 1, controller_name: "comments", action_name: "create"})
      params = ({content: 'comment content', commentable_id: @admin_card.id, commentable_type: "Card", remember_token: @member_user.remember_token})
      comments_count = Comment.count
      response = JSON.parse(post(:create, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
      expect(Comment.count).to eq(comments_count)
    end

    it 'test update end point with admin' do
      Rule.create({user_type: 0, controller_name: "comments", action_name: "update"})
      params = ({id: @comment1.id, content: 'new comment content', commentable_id: @admin_card.id, commentable_type: "Card", remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['id']).to eq(@comment1.id)
      expect(response['data']['content']).to eq('new comment content')
    end

    it 'test update end point with admin with comment on his list' do
      Rule.create({user_type: 0, controller_name: "comments", action_name: "update"})
      params = ({id: @comment2.id, content: 'new comment content', commentable_id: @member_card.id, commentable_type: "Card", remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['id']).to eq(@comment2.id)
      expect(response['data']['content']).to eq('new comment content')
    end

    it 'test update end point with not authorized admin' do
      Rule.create({user_type: 0, controller_name: "comments", action_name: "update"})
      params = ({id: @comment3.id, content: 'new comment content', commentable_id: @user_card.id, commentable_type: "Card", remember_token: @admin_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
    end

    it 'test update end point with member' do
      Rule.create({user_type: 1, controller_name: "comments", action_name: "update"})
      params = ({id: @comment2.id, content: 'new comment content', commentable_id: @member_card.id, commentable_type: "Card", remember_token: @member_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['id']).to eq(@comment2.id)
      expect(response['data']['content']).to eq('new comment content')
    end

    it 'test update end point with not authorized member' do
      Rule.create({user_type: 1, controller_name: "comments", action_name: "update"})
      params = ({id: @comment3.id, content: 'new comment content', commentable_id: @user_card.id, commentable_type: "Card", remember_token: @member_user.remember_token})
      response = JSON.parse(post(:update, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
    end

    it 'test delete end point with admin' do
      Rule.create({user_type: 0, controller_name: "comments", action_name: "delete"})
      params = ({id: @comment1.id, remember_token: @admin_user.remember_token})
      comments_count = Comment.count
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['id']).to eq(@comment1.id)
      expect(Comment.count).to eq(comments_count - 1)
    end

    it 'test delete end point with admin with comment on his list' do
      Rule.create({user_type: 0, controller_name: "comments", action_name: "delete"})
      params = ({id: @comment2.id, remember_token: @admin_user.remember_token})
      comments_count = Comment.count
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['id']).to eq(@comment2.id)
      expect(Comment.count).to eq(comments_count - 1)
    end

    it 'test delete end point with not authorized admin' do
      Rule.create({user_type: 0, controller_name: "comments", action_name: "delete"})
      params = ({id: @comment3.id, remember_token: @admin_user.remember_token})
      comments_count = Comment.count
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
      expect(Comment.count).to eq(comments_count)
    end


    it 'test delete end point with member' do
      Rule.create({user_type: 1, controller_name: "comments", action_name: "delete"})
      params = ({id: @comment2.id, remember_token: @member_user.remember_token})
      comments_count = Comment.count
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['id']).to eq(@comment2.id)
      expect(Comment.count).to eq(comments_count - 1)
    end

    it 'test delete end point with not authorized member' do
      Rule.create({user_type: 1, controller_name: "comments", action_name: "delete"})
      params = ({id: @comment3.id, remember_token: @member_user.remember_token})
      comments_count = Comment.count
      response = JSON.parse(post(:delete, params).body)
      expect(response['data']['message']).to eq('Not Authorized')
      expect(Comment.count).to eq(comments_count)
    end
  end
end