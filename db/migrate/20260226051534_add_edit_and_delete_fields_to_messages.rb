class AddEditAndDeleteFieldsToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :edited_at, :datetime unless column_exists?(:messages, :edited_at)
    add_column :messages, :deleted_at, :datetime unless column_exists?(:messages, :deleted_at)
    add_index :messages, :deleted_at unless index_exists?(:messages, :deleted_at)
  end
end
