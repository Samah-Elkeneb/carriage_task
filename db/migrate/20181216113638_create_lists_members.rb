class CreateListsMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :lists_members do |t|
    	t.integer :list_id
      	t.integer :member_id
    	t.integer :creator_id
    	t.timestamps null: false
    end
  end
end
