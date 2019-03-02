class CreateRules < ActiveRecord::Migration[5.0]
  def change
    create_table :rules do |t|
      t.integer :user_type
      t.string :controller_name
      t.string :action_name
      t.timestamps null: false
    end
  end
end
