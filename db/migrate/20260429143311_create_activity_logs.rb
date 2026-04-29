class CreateActivityLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :activity_logs do |t|
      t.references :trackable,  null: false, polymorphic: true
      t.references :actor,      null: false, foreign_key: { to_table: :users }
      t.string     :action,     null: false
      t.jsonb      :metadata,   null: false, default: {}
      t.timestamps
    end
    add_index :activity_logs, [ :trackable_type, :trackable_id ]
  end
end
