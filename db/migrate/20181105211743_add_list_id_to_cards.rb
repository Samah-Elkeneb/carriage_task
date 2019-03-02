class AddListIdToCards < ActiveRecord::Migration[5.0]
  def change
  	add_column :cards,:list_id,:integer
  end
end
