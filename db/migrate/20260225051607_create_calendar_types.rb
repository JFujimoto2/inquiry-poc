class CreateCalendarTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_types do |t|
      t.date :date, null: false
      t.string :day_type, null: false

      t.timestamps
    end
    add_index :calendar_types, :date, unique: true
  end
end
