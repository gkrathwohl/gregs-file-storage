class RenameColumns < ActiveRecord::Migration
  def change
    rename_column :uploads, :type, :file_extension
    rename_column :uploads, :url, :s3_name
  end
end
