class Comment < ApplicationRecord
	include CreationRelation

  LIMIT = 2
	belongs_to :commentable, polymorphic: true
	validates_presence_of :content

end