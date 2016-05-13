class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :saved, default: 0
      t.integer :faulty, default: 0
      t.integer :existing, default: 0
      t.integer :total, default: 0

      t.timestamps null: false
    end
  end
end
