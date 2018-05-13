class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :id_string
      t.string :display_name
      t.string :photo_url

      t.timestamps
    end

    add_index :users, :id_string, unique: true
  end
end
