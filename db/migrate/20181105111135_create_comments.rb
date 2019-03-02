class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
    	t.string :content
    	t.integer :commentable_id
    	t.string :commentable_type
    	t.string :parent
    	t.integer :creator_id
    	t.timestamps null: false
    end
  end
end