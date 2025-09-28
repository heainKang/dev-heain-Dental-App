class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.integer :rating
      t.text :comment
      t.references :job, null: false, foreign_key: true
      t.references :reviewer, polymorphic: true, null: false
      t.references :reviewee, polymorphic: true, null: false

      t.timestamps
    end
  end
end
