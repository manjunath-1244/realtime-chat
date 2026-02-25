class CreateRoomMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :room_members do |t|
      t.references :room, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role
      t.datetime :joined_at

      t.timestamps
    end
  end
end
