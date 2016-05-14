class CreateGameStateRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :game_state_relationships do |t|
      t.integer :room_id
      t.integer :game_state_id

      t.timestamps
    end
  end
end
