class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_one :profile, dependent: :destroy
  has_one :hospital, dependent: :destroy
  has_many :matchings, dependent: :destroy
  has_many :applied_jobs, through: :matchings, source: :job
  has_many :reviews_as_reviewer, class_name: 'Review', foreign_key: 'reviewer_id'
  has_many :reviews_as_reviewee, class_name: 'Review', foreign_key: 'reviewee_id'
  has_many :notifications, dependent: :destroy

  # Instance methods for notifications
  def unread_notifications_count
    notifications.unread.count
  end

  def has_unread_notifications?
    unread_notifications_count > 0
  end

  # Enums
  enum :role, {
    jobseeker: 0,
    hospital: 1,
    admin: 2
  }

  # Validations
  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true
  validates :role, presence: true

  # Callbacks
  after_create :create_profile, if: :jobseeker?

  private

  def create_profile
    Profile.create(
      user: self,
      age: 25,  # 기본값
      desired_hourly_rate: 50000,  # 기본값
      experience_years: 0  # 기본값
    )
  end
end
