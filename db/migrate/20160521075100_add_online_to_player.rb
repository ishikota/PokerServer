class AddOnlineToPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :online, :boolean, default: false, null: false
  end
end
