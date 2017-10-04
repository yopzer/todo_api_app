class CreateTagsTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tags_tasks, id: false do |t|
      t.references :tag
      t.references :task
    end
  end
end
