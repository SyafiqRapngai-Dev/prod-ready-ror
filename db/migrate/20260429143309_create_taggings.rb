class CreateTaggings < ActiveRecord::Migration[8.0]
  def change
    create_table :taggings do |t|
      t.references :label,    null: false, foreign_key: true
      t.references :taggable, null: false, polymorphic: true
      t.timestamps
    end
    add_index :taggings, [ :label_id, :taggable_type, :taggable_id ], unique: true
  end
end
