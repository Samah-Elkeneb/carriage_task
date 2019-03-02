class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
    	t.string :user_name
      t.string :email
	    t.string :password_digest
	    t.integer :user_type
      t.timestamps null: false
    end
  end
end
