class ShowCardSerializer < CardSerializer
  has_many :comments, serializer: CommentSerializer do
  	@object.comments.limit(3)
  end
end
