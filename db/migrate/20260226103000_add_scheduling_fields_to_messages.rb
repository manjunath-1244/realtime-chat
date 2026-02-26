class AddSchedulingFieldsToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :scheduled_for, :datetime unless column_exists?(:messages, :scheduled_for)
    add_column :messages, :published_at, :datetime unless column_exists?(:messages, :published_at)

    add_index :messages, :scheduled_for unless index_exists?(:messages, :scheduled_for)
    add_index :messages, :published_at unless index_exists?(:messages, :published_at)
  end
end
