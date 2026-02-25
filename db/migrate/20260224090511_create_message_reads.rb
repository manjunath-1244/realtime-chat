class CreateMessageReads < ActiveRecord::Migration[7.1]
  def change
    create_table :message_reads do |t|
      t.references :message, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :read_at

      t.timestamps
    end
  end
end
