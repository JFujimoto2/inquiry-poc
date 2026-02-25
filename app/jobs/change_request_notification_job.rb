class ChangeRequestNotificationJob < ApplicationJob
  queue_as :default

  def perform(change_request)
    ChangeRequestMailer.admin_notification(change_request).deliver_now
  end
end
