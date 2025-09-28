class AddPhoneToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :phone, :string
  end
end
