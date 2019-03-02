class User < ApplicationRecord
  cattr_accessor :current_user
  validates_presence_of :email, :user_name, :user_type
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of :email
  has_secure_password

  has_many :lists_members, foreign_key: 'member_id',  dependent: :delete_all
  has_many :lists, through: :lists_members

  enum user_type: {admin: 0, member: 1}
  before_create :update_remember_token

  def update_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

  def admin?
    user_type == 'admin'
  end
end