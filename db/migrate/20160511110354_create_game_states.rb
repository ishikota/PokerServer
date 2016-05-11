class CreateGameStates < ActiveRecord::Migration[5.0]
  def change
    create_table :game_states do |t|
      t.string :state
    end
  end
end
