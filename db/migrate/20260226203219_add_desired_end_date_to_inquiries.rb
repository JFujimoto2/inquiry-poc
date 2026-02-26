class AddDesiredEndDateToInquiries < ActiveRecord::Migration[8.1]
  def up
    add_column :inquiries, :desired_end_date, :date

    execute <<~SQL
      UPDATE inquiries SET desired_end_date = desired_date WHERE desired_end_date IS NULL
    SQL

    change_column_null :inquiries, :desired_end_date, false
  end

  def down
    remove_column :inquiries, :desired_end_date
  end
end
