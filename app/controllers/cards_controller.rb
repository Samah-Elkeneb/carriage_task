class CardsController < ApplicationController
  before_action :authenticate_user, :authorized_user?
  @@allowed_params = [:id, :title, :description, :list_id, comments: [:id]]

  def all_cards
    get_response(GetAllCards)
  end

  def show
    get_response(GetCardById, card_params)
  end

  def create
    get_response(CreateCard, card_params)
  end

  def update
    get_response(UpdateCard, card_params)
  end

  def delete
    get_response(Delete, card_params)
  end

  private
  def card_params
    params.permit(*@@allowed_params).merge(model: Card)
  end
end