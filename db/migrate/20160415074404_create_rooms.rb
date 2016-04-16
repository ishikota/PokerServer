class CreateRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer :max_round
      t.integer :player_num

      t.timestamps
    end
  end
end
