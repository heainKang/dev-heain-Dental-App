class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:show, :update]

  def index
    @notifications = current_user.notifications.recent.limit(50)
    @unread_count = current_user.unread_notifications_count
  end

  def show
    @notification.mark_as_read! if @notification.unread?
    
    # Redirect to the related object if it exists
    if @notification.notifiable
      redirect_to notification_redirect_path(@notification)
    else
      redirect_to notifications_path
    end
  end

  def update
    case params[:action_type]
    when 'mark_as_read'
      @notification.mark_as_read!
      render json: { status: 'success', read: true }
    when 'mark_as_unread'
      @notification.mark_as_unread!
      render json: { status: 'success', read: false }
    when 'mark_all_as_read'
      current_user.notifications.unread.update_all(read_at: Time.current)
      render json: { status: 'success', message: '모든 알림을 읽음으로 처리했습니다.' }
    else
      render json: { status: 'error', message: '잘못된 요청입니다.' }
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end

  def notification_redirect_path(notification)
    case notification.notifiable_type
    when 'Job'
      job_path(notification.notifiable)
    when 'Matching'
      my_applications_path
    else
      notifications_path
    end
  end
end
