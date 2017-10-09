require 'rails_helper'

RSpec.describe 'Tag' do
  describe 'uniqueness validation' do
    it 'validates title uniqueness' do
      tag_a = Api::V1::Tag.create(title: 'test1')
      tag_b = Api::V1::Tag.new(title: 'test1')

      expect(tag_b.save).to eq(false)
      expect(tag_b.errors[:title]).to eq ['has already been taken']
    end
  end
end
