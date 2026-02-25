class AddTemplateTypeToEmailTemplates < ActiveRecord::Migration[8.1]
  def change
    add_column :email_templates, :template_type, :string, null: false, default: "quote"

    remove_index :email_templates, :facility_id, unique: true
    add_index :email_templates, [ :facility_id, :template_type ], unique: true
  end
end
