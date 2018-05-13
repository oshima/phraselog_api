class CreatePhrases < ActiveRecord::Migration[5.1]
  def change
    create_table :phrases do |t|
      t.string :id_string
      t.string :title
      t.float :interval
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :phrases, :id_string, unique: true
  end
end
