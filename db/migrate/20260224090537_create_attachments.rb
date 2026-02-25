class CreateAttachments < ActiveRecord::Migration[7.1]
  def change
    create_table :attachments do |t|
      t.references :message, null: false, foreign_key: true
      t.string :file_url
      t.string :file_type

      t.timestamps
    end
  end
end
