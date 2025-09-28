class Review < ApplicationRecord
  belongs_to :job
  belongs_to :reviewer, polymorphic: true
  belongs_to :reviewee, polymorphic: true

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10, maximum: 500 }
  validates :job_id, uniqueness: { scope: [:reviewer_id, :reviewer_type] }

  # Scopes
  scope :positive, -> { where('rating >= ?', 4) }
  scope :negative, -> { where('rating <= ?', 2) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(reviewee: user) }
  scope :by_user, ->(user) { where(reviewer: user) }

  # Instance methods
  def positive?
    rating >= 4
  end

  def negative?
    rating <= 2
  end

  def neutral?
    rating == 3
  end

  def rating_text
    case rating
    when 5
      "매우 만족"
    when 4
      "만족"
    when 3
      "보통"
    when 2
      "불만족"
    when 1
      "매우 불만족"
    else
      "평가 없음"
    end
  end

  def short_comment
    comment.length > 50 ? "#{comment[0..50]}..." : comment
  end
end
