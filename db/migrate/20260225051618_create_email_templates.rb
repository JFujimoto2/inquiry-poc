class CreateEmailTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :email_templates do |t|
      t.references :facility, null: false, foreign_key: true, index: { unique: true }
      t.string :subject, null: false
      t.text :body, null: false

      t.timestamps
    end
  end
end
