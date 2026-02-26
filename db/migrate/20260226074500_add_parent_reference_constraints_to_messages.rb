class AddParentReferenceConstraintsToMessages < ActiveRecord::Migration[7.0]
  def change
    add_index :messages, :parent_id unless index_exists?(:messages, :parent_id)
    add_foreign_key :messages, :messages, column: :parent_id unless foreign_key_exists?(:messages, :messages, column: :parent_id)
  end
end
