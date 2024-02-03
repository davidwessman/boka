class CreateWeeks < ActiveRecord::Migration[7.1]
  def change
    create_table :weeks do |t|
      t.integer :number
      t.datetime :scraped_at

      t.timestamps
    end
  end
end
