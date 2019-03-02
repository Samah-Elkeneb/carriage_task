class List < ApplicationRecord
  include CreationRelation

  validates_presence_of :title
  has_many :cards
  has_many :lists_members, dependent: :delete_all
  has_many :members, through: :lists_members, class_name: 'User', source: 'member'
  scope :member_lists, -> {joins(:members).where(users: {id: User.current_user.id})}
end