class CreateChannels < ActiveRecord::Migration[6.0]
  def change
    create_table :channels do |t|
      t.integer :user_id, null: false
      t.string :adapter, limit: 16
      t.string :channel_id, limit: 128
      t.timestamps
    end

    add_foreign_key :channels, :users
    add_index :channels, [:adapter, :channel_id], unique: true
  end
end
