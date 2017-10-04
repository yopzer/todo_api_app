class Api::V1::Task < ApplicationRecord
  has_and_belongs_to_many :tags

  validates :title, presence: true
end
