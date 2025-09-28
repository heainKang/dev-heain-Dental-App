class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_jobseeker
  before_action :set_profile, only: [:show, :edit, :update]

  def new
    @profile = current_user.build_profile
  end

  def create
    @profile = current_user.build_profile(profile_params)
    
    if @profile.save
      redirect_to profile_path(@profile), notice: "프로필이 성공적으로 생성되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @work_history = @profile.work_experiences.order(start_date: :desc) if @profile.respond_to?(:work_experiences)
    @applications = current_user.matchings.includes(:job => :hospital).recent.limit(10)
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path(@profile), notice: "프로필이 성공적으로 업데이트되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_availability
    @profile = current_user.profile
    @profile.update(available_immediately: !@profile.available_immediately)
    
    status_text = @profile.available_immediately? ? "즉시 근무 가능" : "근무 불가능"
    redirect_back(fallback_location: profile_path(@profile), notice: "출근 상태가 '#{status_text}'로 변경되었습니다.")
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
    redirect_to root_path unless @profile.user == current_user
  end

  def profile_params
    params.require(:profile).permit(
      :age, :phone, :desired_hourly_rate, :experience_years, 
      :qualification, :bio, :available_immediately, :preferred_work_days,
      :preferred_start_time, :preferred_end_time, :address, :emergency_contact,
      :emergency_contact_phone, :license_number, :specialties
    )
  end

  def ensure_jobseeker
    unless current_user.jobseeker?
      redirect_to root_path, alert: "구직자만 접근할 수 있습니다."
    end
  end
end
