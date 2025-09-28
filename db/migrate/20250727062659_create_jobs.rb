class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.decimal :hourly_rate
      t.date :work_date
      t.time :start_time
      t.time :end_time
      t.integer :status
      t.references :hospital, null: false, foreign_key: true

      t.timestamps
    end
  end
end
