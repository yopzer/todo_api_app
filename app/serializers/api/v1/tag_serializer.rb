class Api::V1::TagSerializer < ActiveModel::Serializer
  type 'tags'

  attributes :id, :title
end
