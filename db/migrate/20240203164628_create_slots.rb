class CreateSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :slots do |t|
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.references :location, null: false, foreign_key: true
      t.references :week, null: false, foreign_key: true

      t.index %i[location_id start_at end_at], unique: true

      t.timestamps
    end
  end
end
