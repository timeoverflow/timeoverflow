class SendPushNotificationsJob < ActiveJob::Base
  queue_as :cron

  def perform
    push_notifications = PushNotification.where(processed_at: nil)

    ::PushNotifications::Broadcast.new(push_notifications: push_notifications).send
  end
end