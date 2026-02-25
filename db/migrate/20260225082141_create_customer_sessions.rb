class CreateCustomerSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_sessions do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :customer_sessions, :token_digest, unique: true
  end
end
