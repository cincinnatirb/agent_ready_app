class CreateParcels < ActiveRecord::Migration[7.2]
  def change
    create_table :parcels do |t|
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :zip_code

      t.timestamps
    end
  end
end
