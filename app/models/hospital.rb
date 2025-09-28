class Hospital < ApplicationRecord
  belongs_to :user
  has_many :jobs, dependent: :destroy
  has_many :matchings, through: :jobs

  # Geocoding
  geocoded_by :address
  after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? }

  # Validations
  validates :name, presence: true
  validates :address, presence: true
  validates :phone, presence: true
  validates :user_id, uniqueness: true

  # Scopes
  scope :with_active_jobs, -> { joins(:jobs).where(jobs: { status: :active }).distinct }
  scope :near_location, ->(latitude, longitude, distance = 10) {
    near([latitude, longitude], distance)
  }

  # Instance methods
  def active_jobs_count
    jobs.active.count
  end

  def average_rating
    # TODO: Calculate from reviews
    0.0
  end

  def full_address
    address
  end
end
