class CardSerializer < ApplicationSerializer
	include CreatorSerializer
	attribute :title
	attribute :description
	attribute :list_id
	has_many :comments, serializer: CommentSerializer #do
	# 	@object.comments.limit(3)
	# end
end
