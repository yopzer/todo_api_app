class Api::V1::Tag < ApplicationRecord
  has_and_belongs_to_many :tasks

  validates :title, presence: true, uniqueness: true

  scope :by_title, -> (q){ where("title like :q", { q: "%#{q}%" }) }
end
