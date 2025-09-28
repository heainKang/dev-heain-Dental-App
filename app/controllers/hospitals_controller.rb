class HospitalsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_hospital_user, only: [:new, :create]
  before_action :set_hospital, only: [:show, :edit, :update, :dashboard]

  def index
    @hospitals = Hospital.includes(:user).order(created_at: :desc)
  end

  def show
    @jobs = @hospital.jobs.active.includes(:matchings).order(created_at: :desc)
  end

  def new
    # Check if user already has a hospital
    if current_user.hospital.present?
      redirect_to hospital_dashboard_path(current_user.hospital)
      return
    end
    
    @hospital = Hospital.new
  end

  def create
    @hospital = Hospital.new(hospital_params)
    @hospital.user = current_user

    if @hospital.save
      redirect_to hospital_dashboard_path(@hospital), notice: "병원이 성공적으로 등록되었습니다!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @hospital.update(hospital_params)
      redirect_to hospital_dashboard_path(@hospital), notice: "병원 정보가 업데이트되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def dashboard
    @stats = {
      total_jobs: @hospital.jobs.count,
      active_jobs: @hospital.jobs.active.count,
      total_applications: @hospital.jobs.joins(:matchings).count,
      pending_applications: @hospital.jobs.joins(:matchings).where(matchings: { status: :applied }).count
    }
    @recent_jobs = @hospital.jobs.includes(:matchings).order(created_at: :desc).limit(5)
    @recent_applications = @hospital.matchings.includes(:user, :job).order(created_at: :desc).limit(5)
  end

  private

  def set_hospital
    @hospital = Hospital.find(params[:id])
  end

  def hospital_params
    params.require(:hospital).permit(:name, :address, :phone, :description, :website, :business_registration_number)
  end

  def ensure_hospital_user
    unless current_user.hospital?
      redirect_to root_path, alert: "병원 관리자만 접근할 수 있습니다."
    end
  end
end
