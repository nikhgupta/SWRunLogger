class CreateSprints < ActiveRecord::Migration
  def change
    create_table :sprints do |t|
      t.references :import, index: true, foreign_key: true
      t.references :scenario, index: true, foreign_key: true

      t.string :digest, limit: 32
      t.boolean :win
      t.integer :time_taken
      t.datetime :started_at

      t.timestamps null: false
    end
  end
end
