class ApplicationSerializer < ActiveModel::Serializer
	attribute :id, if: -> { object.respond_to?(:id) }
	attribute :created_at, if: -> { object.respond_to?(:created_at) }
	attribute :updated_at, if: -> { object.respond_to?(:updated_at) }
end