	class ListSerializer < ApplicationSerializer
		include CreatorSerializer
		attribute :title
		has_many :cards, serializer: CardSerializer
		has_many :members, serializer: UserSerializer
	end
