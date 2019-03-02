class ListsMember < ApplicationRecord
  include CreationRelation
  
  belongs_to :list
  belongs_to :member, foreign_key: :member_id, class_name: 'User'
end