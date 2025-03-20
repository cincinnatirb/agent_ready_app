class CreateStructures < ActiveRecord::Migration[7.2]
  def change
    create_table :structures do |t|
      t.string :building_type, null: false
      t.string :nickname
      t.integer :length, null: false
      t.integer :width, null: false
      t.references :parcel, null: false, foreign_key: true

      t.timestamps
    end
  end
end
