class SendScheduledMessageJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Message.find_by(id: message_id)
    return if message.blank? || message.deleted? || message.published?
    return if message.scheduled_for.present? && message.scheduled_for > Time.current

    message.publish_now!
    AuditLog.create!(
      user: message.user,
      room: message.room,
      event_type: "message_published",
      auditable: message,
      metadata: {
        scheduled_for: message.scheduled_for,
        published_at: message.published_at
      }
    )
  rescue StandardError => e
    Rails.logger.error("AuditLog write failed in SendScheduledMessageJob: #{e.class} - #{e.message}")
  end
end
