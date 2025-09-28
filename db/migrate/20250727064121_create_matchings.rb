class CreateMatchings < ActiveRecord::Migration[8.0]
  def change
    create_table :matchings do |t|
      t.integer :status
      t.references :job, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
