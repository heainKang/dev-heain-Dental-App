class UsersController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    case current_user.role
    when 'hospital'
      if current_user.hospital
        redirect_to hospital_dashboard_path(current_user.hospital)
      else
        redirect_to new_hospital_path
      end
    when 'jobseeker'
      @profile = current_user.profile
      @recent_applications = current_user.matchings.includes(:job => :hospital).order(created_at: :desc).limit(5)
      @recommended_jobs = Job.active.includes(:hospital).limit(6)
      @stats = {
        total_applications: current_user.matchings.count,
        pending_applications: current_user.matchings.where(status: :applied).count,
        accepted_applications: current_user.matchings.where(status: :accepted).count
      }
    when 'admin'
      redirect_to admin_root_path
    else
      redirect_to root_path
    end
  end

  def my_jobs
    redirect_to root_path unless current_user.jobseeker?
    @jobs = current_user.applied_jobs.includes(:hospital).order(created_at: :desc)
  end

  def my_applications
    redirect_to root_path unless current_user.jobseeker?
    @applications = current_user.matchings.includes(:job => :hospital).order(created_at: :desc)
  end

  def my_hospital
    redirect_to root_path unless current_user.hospital?
    @hospital = current_user.hospital
    if @hospital
      redirect_to hospital_dashboard_path(@hospital)
    else
      redirect_to new_hospital_path
    end
  end
end