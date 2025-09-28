class Profile < ApplicationRecord
  belongs_to :user

  # Geocoding
  geocoded_by :address
  after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? }

  # Validations
  validates :user_id, uniqueness: true
  validates :age, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :phone, presence: true, format: { with: /\A010\d{8}\z/, message: "010으로 시작하는 11자리 번호를 입력해주세요" }
  validates :desired_hourly_rate, presence: true, numericality: { greater_than: 0 }
  validates :experience_years, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Optional field validations
  validates :emergency_contact_phone, format: { with: /\A010\d{8}\z/, message: "010으로 시작하는 11자리 번호를 입력해주세요" }, allow_blank: true
  validates :license_number, length: { maximum: 50 }, allow_blank: true

  # Enums
  enum :preferred_schedule_type, {
    regular: 'regular',        # 정규 근무
    flexible: 'flexible',      # 유연 근무
    part_time: 'part_time',    # 파트타임
    temporary: 'temporary'     # 임시/대타
  }

  enum :shift_preference, {
    day: 'day',               # 주간 근무
    night: 'night',           # 야간 근무
    rotating: 'rotating',     # 교대 근무
    shift_flexible: 'shift_flexible'      # 유연 근무
  }

  # Scopes
  scope :available_now, -> { where(available_immediately: true) }
  scope :with_experience, ->(min_years) { where('experience_years >= ?', min_years) }
  scope :by_hourly_rate, ->(min_rate, max_rate) {
    where(desired_hourly_rate: min_rate..max_rate) if min_rate && max_rate
  }
  scope :weekend_available, -> { where(weekend_availability: true) }
  scope :night_shift_available, -> { where(night_shift_available: true) }
  scope :emergency_available, -> { where(emergency_availability: true) }
  scope :with_address, -> { where.not(address: [nil, '']) }
  scope :with_specialties, -> { where.not(specialties: [nil, '']) }

  # Instance methods
  def is_available_immediately?
    available_immediately
  end

  def experience_level
    case experience_years
    when 0
      "신입"
    when 1..2
      "초급"
    when 3..5
      "중급"
    else
      "고급"
    end
  end

  def qualification_list
    qualification.present? ? qualification.split(',').map(&:strip) : []
  end

  def specialties_list
    specialties.present? ? specialties.split(',').map(&:strip) : []
  end

  def preferred_work_days_list
    preferred_work_days.present? ? preferred_work_days.split(',').map(&:strip) : []
  end

  def add_qualification(qual)
    current_quals = qualification_list
    current_quals << qual.strip unless current_quals.include?(qual.strip)
    self.qualification = current_quals.join(', ')
  end

  def add_specialty(specialty)
    current_specialties = specialties_list
    current_specialties << specialty.strip unless current_specialties.include?(specialty.strip)
    self.specialties = current_specialties.join(', ')
  end

  def has_complete_profile?
    [
      age, phone, desired_hourly_rate, experience_years,
      qualification, bio, address
    ].all?(&:present?)
  end

  def completion_percentage
    total_fields = 12 # 주요 필드 개수
    completed_fields = [
      age, phone, desired_hourly_rate, experience_years,
      qualification, bio, address, license_number,
      specialties, emergency_contact, preferred_work_days
    ].count(&:present?)
    
    (completed_fields.to_f / total_fields * 100).round
  end

  def average_rating
    # TODO: Calculate from reviews
    0.0
  end

  def full_address
    address.present? ? address : "주소 미등록"
  end

  def formatted_preferred_time
    if preferred_start_time.present? && preferred_end_time.present?
      "#{preferred_start_time.strftime('%H:%M')} - #{preferred_end_time.strftime('%H:%M')}"
    else
      "시간 미설정"
    end
  end
end
