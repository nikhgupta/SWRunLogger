class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.references :sprint, index: true, foreign_key: true
      t.string :type
      t.integer :mana
      t.integer :crystal
      t.integer :energy
      t.integer :amount
      t.integer :level

      t.timestamps null: false
    end
  end
end
