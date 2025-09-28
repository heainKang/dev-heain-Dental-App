class AddWorkScheduleToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :preferred_schedule_type, :string, default: 'regular'
    add_column :profiles, :shift_preference, :string, default: 'day'
    add_column :profiles, :weekend_availability, :boolean, default: false
    add_column :profiles, :night_shift_available, :boolean, default: false
    add_column :profiles, :emergency_availability, :boolean, default: false
    add_column :profiles, :commute_distance, :integer, default: 10
    add_column :profiles, :notification_preferences, :text
  end
end
