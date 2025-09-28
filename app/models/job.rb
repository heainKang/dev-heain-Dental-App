class Job < ApplicationRecord
  belongs_to :hospital
  has_many :matchings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :applicants, -> { where(matchings: { status: :applied }) }, through: :matchings, source: :user

  # Enums
  enum :status, { 
    draft: 0,
    active: 1, 
    filled: 2, 
    cancelled: 3,
    completed: 4 
  }

  # Validations
  validates :title, presence: true
  validates :description, presence: true
  validates :hourly_rate, presence: true, numericality: { greater_than: 0 }
  validates :work_date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true
  validate :work_date_cannot_be_in_the_past
  validate :end_time_after_start_time

  # Scopes
  scope :available, -> { where(status: :active) }
  scope :today, -> { where(work_date: Date.current) }
  scope :tomorrow, -> { where(work_date: Date.tomorrow) }
  scope :urgent, -> { where(work_date: [Date.current, Date.tomorrow]) }
  scope :by_hourly_rate, ->(min_rate, max_rate) {
    where(hourly_rate: min_rate..max_rate) if min_rate && max_rate
  }

  # Instance methods
  def duration_hours
    return 0 unless start_time && end_time
    ((end_time - start_time) / 1.hour).round(1)
  end

  def total_payment
    duration_hours * hourly_rate
  end

  def is_urgent?
    work_date <= Date.tomorrow
  end

  def can_apply?
    active? && work_date >= Date.current
  end

  private

  def work_date_cannot_be_in_the_past
    return unless work_date.present?
    
    if work_date < Date.current
      errors.add(:work_date, "can't be in the past")
    end
  end

  def end_time_after_start_time
    return unless start_time.present? && end_time.present?
    
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
