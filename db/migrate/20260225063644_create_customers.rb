class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :company_name, null: false
      t.string :contact_name, null: false
      t.string :email, null: false
      t.string :phone
      t.text :notes

      t.timestamps
    end

    add_index :customers, :email, unique: true
  end
end
