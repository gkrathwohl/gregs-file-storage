class AddTextColumnToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :full_text, :text
  end
end
