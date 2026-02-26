class AddParentIdToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :parent_id, :bigint
  end
end
