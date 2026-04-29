class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.references :organization, null: false, foreign_key: true
      t.string  :name,        null: false
      t.string  :key,         null: false
      t.text    :description
      t.integer :status,      null: false, default: 0
      t.timestamps
    end
    add_index :projects, [ :organization_id, :key ], unique: true
  end
end
