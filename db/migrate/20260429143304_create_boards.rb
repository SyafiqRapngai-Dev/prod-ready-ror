class CreateBoards < ActiveRecord::Migration[8.0]
  def change
    create_table :boards do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false, default: "Main Board"
      t.timestamps
    end
  end
end
