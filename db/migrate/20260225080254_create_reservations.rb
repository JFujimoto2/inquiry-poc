class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.references :inquiry, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :facility, null: false, foreign_key: true
      t.string :status, null: false, default: "pending_confirmation"
      t.date :check_in_date, null: false
      t.date :check_out_date
      t.integer :num_people, null: false
      t.integer :total_amount
      t.text :admin_notes
      t.datetime :confirmed_at
      t.datetime :cancelled_at

      t.timestamps
    end

    add_index :reservations, :status
  end
end
