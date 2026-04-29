class AddBodyToComments < ActiveRecord::Migration[8.0]
  def change
    add_column :comments, :body, :text, null: false, default: ""
  end
end
