class CreateContests < ActiveRecord::Migration[6.0]
  def change
    create_table :contests do |t|
      t.string :name, limit: 64
      t.string :short_name, limit: 32, unique: true
      t.datetime :start_time
      t.datetime :end_time
      t.string :topic, limit: 64
      t.text :description
      t.boolean :karel
      t.boolean :cpp
      t.timestamps
    end
    add_index :contests, :short_name, unique: true
  end
end
