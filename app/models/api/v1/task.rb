class Api::V1::Task < ApplicationRecord
  has_and_belongs_to_many :tags

  validates :title, presence: true

  def tags=(tag_list)
    tag_instances = tag_list.map do |tag_title|
      Api::V1::Tag.where(title: tag_title).first_or_create!
    end

    super(tag_instances)
  end
end
