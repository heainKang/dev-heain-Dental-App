class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    if user_signed_in?
      redirect_to_dashboard
    else
      @urgent_jobs = Job.urgent.active.includes(:hospital).limit(5)
      @recent_hospitals = Hospital.with_active_jobs.limit(5)
      @stats = {
        total_jobs: Job.active.count,
        total_hospitals: Hospital.count,
        urgent_jobs: Job.urgent.active.count
      }
    end
  end

  private

  def redirect_to_dashboard
    case current_user.role
    when 'hospital'
      redirect_to hospitals_path
    when 'jobseeker'
      redirect_to jobs_path
    when 'admin'
      redirect_to admin_dashboard_path
    else
      # Stay on home page for undefined roles
    end
  end
end
