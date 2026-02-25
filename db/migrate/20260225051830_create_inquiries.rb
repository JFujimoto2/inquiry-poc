class CreateInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :inquiries do |t|
      t.references :facility, null: false, foreign_key: true
      t.date :desired_date, null: false
      t.integer :num_people, null: false
      t.boolean :conference_room, default: false
      t.boolean :accommodation, default: false
      t.boolean :breakfast, default: false
      t.boolean :lunch, default: false
      t.boolean :dinner, default: false
      t.string :company_name, null: false
      t.string :contact_name, null: false
      t.string :email, null: false
      t.integer :total_amount

      t.timestamps
    end
  end
end
