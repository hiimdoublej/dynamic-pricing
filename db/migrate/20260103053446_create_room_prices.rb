class CreateRoomPrices < ActiveRecord::Migration[7.1]
  def change
    create_table :room_prices do |t|
      t.string :period, null: false
      t.string :hotel, null: false
      t.string :room, null: false
      t.integer :price, null: false

      t.datetime :updated_at, null: false
    end
    add_index :room_prices, [:period, :hotel, :room], unique: true
  end
end
