class CreatePrices < ActiveRecord::Migration[7.1]
  def change
    create_table :prices do |t|
      t.string :period, null: false
      t.string :hotel, null: false
      t.string :room, null: false
      t.integer :amount, null: false

      t.timestamps
    end
    add_index :prices, [:period, :hotel, :room], unique: true
  end
end
