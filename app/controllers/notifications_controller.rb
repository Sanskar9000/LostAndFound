class NotificationsController < ApplicationController
  before_action :set_notification, only: :update
  before_action :require_staff, only: %i[new create]

  def index
    @current_filter = params[:filter].in?(%w[all activity faculty messages]) ? params[:filter] : "all"
    @notifications = filtered_notifications
  end

  def new
  end

  def create
    recipients = notification_recipients

    if manual_notification_params[:title].blank? || manual_notification_params[:body].blank?
      flash.now[:alert] = "Title and message are required."
      return render :new, status: :unprocessable_entity
    end

    if recipients.blank?
      flash.now[:alert] = "No recipients found for the selected audience."
      return render :new, status: :unprocessable_entity
    end

    recipients.find_each do |recipient|
      Notification.notify!(
        recipient: recipient,
        actor: current_user,
        title: manual_notification_params[:title],
        body: manual_notification_params[:body],
        kind: :general,
        link_path: search_path
      )
    end

    redirect_to notifications_path, notice: "Notification sent successfully."
  end

  def update
    @notification.mark_as_read! if @notification.recipient == current_user
    redirect_back fallback_location: notifications_path
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end

  def require_staff
    redirect_to notifications_path, alert: "Not authorized." unless current_user.admin? || current_user.faculty?
  end

  def manual_notification_params
    params.require(:notification).permit(:title, :body, :audience)
  end

  def notification_recipients
    scope = User.where.not(id: current_user.id)

    case manual_notification_params[:audience]
    when "students"
      scope.where(role: "student")
    when "faculty"
      scope.where(role: "faculty")
    else
      User.none
    end
  end

  def filtered_notifications
    scope = current_user.notifications.recent

    case @current_filter
    when "faculty"
      scope.where(kind: :general)
    when "messages"
      scope.where(kind: :message_received)
    when "activity"
      scope.where.not(kind: [:general, :message_received])
    else
      scope
    end
  end
end
