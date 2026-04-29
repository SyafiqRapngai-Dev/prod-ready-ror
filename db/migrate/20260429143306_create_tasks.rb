class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :project,    null: false, foreign_key: true
      t.references :column,     null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.integer    :parent_id,  index: true
      t.string     :title,      null: false
      t.integer    :priority,   null: false, default: 1
      t.float      :position,   null: false, default: 0.0
      t.date       :due_date
      t.timestamps
    end
    add_foreign_key :tasks, :tasks, column: :parent_id
  end
end
