class AddUuidToPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :uuid, :string
  end
end
