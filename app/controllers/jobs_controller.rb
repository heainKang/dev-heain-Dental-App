class JobsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @jobs = Job.includes(:hospital).active.order(created_at: :desc)
    
    # Location-based recommendations for logged-in jobseekers
    if current_user&.jobseeker? && current_user.profile&.address.present?
      profile = current_user.profile
      if profile.latitude.present? && profile.longitude.present?
        # Get jobs within 20km of user's location, sorted by distance
        nearby_jobs = Job.includes(:hospital)
                         .joins(:hospital)
                         .where('hospitals.latitude IS NOT NULL AND hospitals.longitude IS NOT NULL')
                         .near([profile.latitude, profile.longitude], 20)
                         .active
        
        # Combine nearby jobs with regular jobs, prioritizing nearby ones
        if nearby_jobs.any?
          distant_jobs = @jobs.where.not(id: nearby_jobs.pluck(:id))
          @jobs = Job.from("(#{nearby_jobs.to_sql} UNION ALL #{distant_jobs.to_sql}) as jobs")
                     .includes(:hospital)
        end
      end
    end
    
    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @jobs = @jobs.joins(:hospital).where(
        "jobs.title ILIKE ? OR jobs.description ILIKE ? OR hospitals.name ILIKE ? OR hospitals.address ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end
    
    # Location filter
    if params[:location].present? && params[:location] != "전체 지역"
      @jobs = @jobs.joins(:hospital).where("hospitals.address ILIKE ?", "%#{params[:location]}%")
    end
    
    # Distance filter for location-based search
    if params[:distance].present? && current_user&.jobseeker? && current_user.profile&.latitude.present?
      distance_km = params[:distance].to_i
      if distance_km > 0
        profile = current_user.profile
        @jobs = @jobs.joins(:hospital)
                     .where('hospitals.latitude IS NOT NULL AND hospitals.longitude IS NOT NULL')
                     .near([profile.latitude, profile.longitude], distance_km)
      end
    end
    
    # Salary filter
    if params[:salary].present? && params[:salary] != "전체 급여"
      case params[:salary]
      when "5만원 이상"
        @jobs = @jobs.where("hourly_rate >= ?", 50000)
      when "10만원 이상"
        @jobs = @jobs.where("hourly_rate >= ?", 100000)
      when "15만원 이상"
        @jobs = @jobs.where("hourly_rate >= ?", 150000)
      end
    end
    
    # Work type filter
    if params[:work_type].present? && params[:work_type] != "전체"
      case params[:work_type]
      when "정규직"
        @jobs = @jobs.where("title ILIKE ?", "%정규직%")
      when "파트타임"
        @jobs = @jobs.where("title ILIKE ?", "%파트타임%")
      when "대타"
        @jobs = @jobs.where("title ILIKE ?", "%대타%")
      end
    end
    
    @urgent_jobs = Job.includes(:hospital).where('work_date <= ?', Date.current + 2.days).order(:work_date)
  end

  def show
    @job = Job.includes(:hospital).find(params[:id])
    @already_applied = current_user.matchings.where(job: @job).exists? if current_user&.jobseeker?
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
  
  def apply
    @job = Job.find(params[:id])
    
    # Check if user is jobseeker
    unless current_user.jobseeker?
      redirect_to @job, alert: "구직자만 지원할 수 있습니다."
      return
    end
    
    # Check if already applied
    if current_user.matchings.where(job: @job).exists?
      redirect_to @job, alert: "이미 지원한 공고입니다."
      return
    end
    
    # Check if job is still available
    unless @job.can_apply?
      redirect_to @job, alert: "더 이상 지원할 수 없는 공고입니다."
      return
    end
    
    # Create matching (application)
    matching = current_user.matchings.build(job: @job, status: :applied)
    
    if matching.save
      redirect_to @job, notice: "성공적으로 지원되었습니다! 병원에서 연락을 드릴 예정입니다."
    else
      redirect_to @job, alert: "지원 중 오류가 발생했습니다. 다시 시도해주세요."
    end
  end
end
