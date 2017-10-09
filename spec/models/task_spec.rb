require 'rails_helper'

RSpec.describe 'Task' do
  describe 'adding already existing tag' do
    it 'it raises error' do
      task = Api::V1::Task.create(title: 'TestTask')
      tag = Api::V1::Tag.create(title: 'test1')

      task.tags << tag

      expect{task.tags << tag}.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
