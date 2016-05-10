class CreateScenarios < ActiveRecord::Migration
  def change
    create_table :scenarios do |t|
      t.string  :name
      t.integer :stage
      t.integer :level, default: 0

      t.timestamps null: false
    end
  end
end
