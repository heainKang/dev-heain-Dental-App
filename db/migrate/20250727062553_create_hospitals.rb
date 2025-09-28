class CreateHospitals < ActiveRecord::Migration[8.0]
  def change
    create_table :hospitals do |t|
      t.string :name
      t.text :address
      t.string :phone
      t.text :description
      t.decimal :latitude
      t.decimal :longitude
      t.text :business_hours
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
