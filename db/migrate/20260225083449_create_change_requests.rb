class CreateChangeRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :change_requests do |t|
      t.references :reservation, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.text :request_details, null: false
      t.string :status, null: false, default: "pending"
      t.text :admin_response

      t.timestamps
    end

    add_index :change_requests, :status
  end
end
