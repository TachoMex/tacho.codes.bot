class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :omegaup_username, limit: 50
      t.string :country, limit: 50
      t.string :state, limit: 50
      t.string :city, limit: 50
      t.string :school, limit: 100
      t.string :email, limit: 100
      t.date :date_of_birth
      t.boolean :karel_coder
      t.boolean :cpp_coder
      t.boolean :allow_newsletter
      t.boolean :admin
      t.timestamps
    end
  end
end
