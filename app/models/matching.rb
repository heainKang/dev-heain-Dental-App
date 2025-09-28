class Matching < ApplicationRecord
  belongs_to :job
  belongs_to :user

  # Enums
  enum :status, {
    applied: 0,
    accepted: 1,
    rejected: 2,
    cancelled: 3,
    completed: 4
  }

  # Validations
  validates :user_id, uniqueness: { scope: :job_id }
  validates :status, presence: true
  validate :user_must_be_jobseeker
  validate :job_must_be_available

  # Scopes
  scope :pending, -> { where(status: :applied) }
  scope :active, -> { where(status: :accepted) }
  scope :finished, -> { where(status: [:completed, :cancelled, :rejected]) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_update :update_job_status, if: :saved_change_to_status?

  # Instance methods
  def can_be_accepted?
    applied? && job.active?
  end

  def can_be_rejected?
    applied?
  end

  def can_be_cancelled?
    applied? || accepted?
  end

  def can_be_completed?
    accepted? && job.work_date <= Date.current
  end

  def hospital
    job.hospital
  end

  def jobseeker
    user
  end

  def duration_in_words
    return "" unless job.start_time && job.end_time
    
    duration = job.duration_hours
    "#{duration}시간"
  end

  def total_payment
    job.total_payment
  end

  private

  def user_must_be_jobseeker
    return unless user.present?
    
    unless user.jobseeker?
      errors.add(:user, "must be a jobseeker")
    end
  end

  def job_must_be_available
    return unless job.present?
    
    unless job.can_apply?
      errors.add(:job, "is not available for application")
    end
  end

  def update_job_status
    case status
    when 'accepted'
      job.update(status: :filled) if job.active?
    when 'completed'
      job.update(status: :completed)
    end
  end
end
