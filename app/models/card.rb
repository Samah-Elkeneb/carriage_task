class Card < ApplicationRecord
	include CreationRelation
	include CommentableModel

	belongs_to :list
	validates_presence_of :title
end