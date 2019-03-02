class CommentSerializer < ApplicationSerializer
  include CreatorSerializer
	attribute :content
	attribute :parent_id
	belongs_to :commentable
end
