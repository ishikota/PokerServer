class CreateEnterRoomRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :enter_room_relationships do |t|
      t.integer :room_id
      t.integer :player_id

      t.timestamps
    end
  end
end
