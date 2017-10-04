class Api::V1::TaskSerializer < ActiveModel::Serializer
  type 'tasks'

  attributes :id, :title

  has_many :tags
end
