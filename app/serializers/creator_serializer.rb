module CreatorSerializer
  extend ActiveSupport::Concern
  included do
    belongs_to :creator, if: -> { object.respond_to?(:creator) }, serializer: UserSerializer
  end
end