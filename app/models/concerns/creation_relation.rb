module CreationRelation
  extend ActiveSupport::Concern
  included do
    belongs_to :creator, foreign_key: :creator_id, class_name: 'User'
    before_validation :set_creator
  end

  def set_creator
    self.creator = User.current_user if respond_to?(:creator_id) && !creator_id.present?
  end
end