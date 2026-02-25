class CreateQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :quotes do |t|
      t.references :inquiry, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.binary :pdf_data
      t.datetime :sent_at

      t.timestamps
    end
  end
end
