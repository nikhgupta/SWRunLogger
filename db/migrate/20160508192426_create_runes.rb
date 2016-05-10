class CreateRunes < ActiveRecord::Migration
  def change
    create_table :runes do |t|
      t.references :reward, index: true, foreign_key: true
      t.integer :grade
      t.integer :sell_value
      t.integer :set
      t.decimal :efficiency, precision: 5, scale: 2, default: 0
      t.integer :slot
      t.integer :rarity
      t.string :primary
      t.string :innate
      t.string :secondary1
      t.string :secondary2
      t.string :secondary3
      t.string :secondary4

      t.timestamps null: false
    end
  end
end
