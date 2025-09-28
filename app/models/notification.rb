class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  # Enum for notification types
  enum :notification_type, {
    job_applied: 'job_applied',
    job_accepted: 'job_accepted',
    job_rejected: 'job_rejected',
    job_completed: 'job_completed',
    new_job_posted: 'new_job_posted',
    profile_reminder: 'profile_reminder',
    system_announcement: 'system_announcement'
  }

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def read?
    read_at.present?
  end

  def unread?
    read_at.nil?
  end

  def mark_as_read!
    update!(read_at: Time.current) if unread?
  end

  def mark_as_unread!
    update!(read_at: nil) if read?
  end

  # Class methods
  def self.create_for_job_application(user, job)
    create!(
      user: user,
      title: "지원 완료",
      message: "#{job.title} 공고에 성공적으로 지원되었습니다.",
      notification_type: :job_applied,
      notifiable: job
    )
  end

  def self.create_for_job_acceptance(user, job)
    create!(
      user: user,
      title: "지원 승인됨",
      message: "#{job.title} 공고 지원이 승인되었습니다! 병원에서 곧 연락드릴 예정입니다.",
      notification_type: :job_accepted,
      notifiable: job
    )
  end

  def self.create_for_new_job(user, job)
    create!(
      user: user,
      title: "새로운 구인공고",
      message: "근처에 새로운 구인공고가 등록되었습니다: #{job.title}",
      notification_type: :new_job_posted,
      notifiable: job
    )
  end
end
