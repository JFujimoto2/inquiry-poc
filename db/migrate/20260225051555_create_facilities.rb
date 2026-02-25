class CreateFacilities < ActiveRecord::Migration[8.1]
  def change
    create_table :facilities do |t|
      t.string :name, null: false
      t.string :sender_email, null: false
      t.string :sender_domain, null: false
      t.text :email_signature

      t.timestamps
    end
    add_index :facilities, :name, unique: true
  end
end
