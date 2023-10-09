class CreateUserContestRelationship < ActiveRecord::Migration[6.0]
  def change
    create_table :user_contest_relationships do |t|
      t.integer :user_id
      t.integer :contest_id
      t.timestamps
    end

    add_foreign_key :user_contest_relationships, :users
    add_foreign_key :user_contest_relationships, :contests
  end
end
