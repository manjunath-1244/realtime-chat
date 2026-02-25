class AddPinnedToMessages < ActiveRecord::Migration[7.0]
  def change
    return if column_exists?(:messages, :pinned)

    add_column :messages, :pinned, :boolean, default: false, null: false
  end
end
