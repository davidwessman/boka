class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.string :title
      t.string :subtitle
      t.string :address
      t.string :postal_code
      t.string :city
      t.string :district
      t.string :facility_id, null: false
      t.string :facility_object_id, null: false
      t.datetime :scraped_at

      t.index(%i[facility_id facility_object_id], unique: true)

      t.timestamps
    end
  end
end
