class AddUniqueIndexToTagsTasks < ActiveRecord::Migration[5.1]
  def change
    add_index :tags_tasks, [:task_id, :tag_id], unique: true
  end
end
