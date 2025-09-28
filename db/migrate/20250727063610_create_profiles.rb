class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.text :qualification
      t.integer :age
      t.decimal :desired_hourly_rate
      t.boolean :available_immediately
      t.integer :experience_years

      t.timestamps
    end
  end
end
