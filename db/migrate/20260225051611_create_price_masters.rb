class CreatePriceMasters < ActiveRecord::Migration[8.1]
  def change
    create_table :price_masters do |t|
      t.references :facility, null: false, foreign_key: true
      t.string :item_type, null: false
      t.string :day_type, null: false
      t.integer :unit_price, null: false

      t.timestamps
    end
    add_index :price_masters, [ :facility_id, :item_type, :day_type ], unique: true
  end
end
