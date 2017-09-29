class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :name
      t.string :description
      t.string :type
      t.datetime :uploadDate

      t.timestamps null: false
    end
  end
end
