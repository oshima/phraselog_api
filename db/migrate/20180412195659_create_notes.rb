class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.integer :x
      t.integer :y
      t.integer :length
      t.references :phrase, foreign_key: true

      t.timestamps
    end
  end
end
