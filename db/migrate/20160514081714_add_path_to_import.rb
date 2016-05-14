class AddPathToImport < ActiveRecord::Migration
  def change
    add_column :imports, :path,         :string
    add_column :imports, :uploaded_at,  :datetime
    add_column :imports, :processed_at, :datetime
  end
end
