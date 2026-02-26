class Message < ApplicationRecord

  # Associations

  belongs_to :user
  belongs_to :room

  belongs_to :parent, class_name: "Message", optional: true
  has_many :replies,
           -> { active.published.order(:created_at) },
           class_name: "Message",
           foreign_key: :parent_id,
           dependent: :destroy

  has_many :message_reads, dependent: :destroy
  has_many :message_reactions, dependent: :destroy

  has_one_attached :file


  # Scopes

  scope :active, -> { where(deleted_at: nil) }
  scope :published, -> { where.not(published_at: nil) }
  scope :visible_in_room, -> { active.where("published_at IS NOT NULL OR (published_at IS NULL AND scheduled_for IS NULL)") }
  scope :pinned, -> { where(pinned: true) }
  scope :top_level, -> { where(parent_id: nil) }

  # Validations

  validate :content_or_file_present
  validate :parent_in_same_room
  validate :scheduled_for_cannot_be_past
  validate :scheduled_for_immutable_after_publish


  # Callbacks
 
  after_create_commit :publish_or_enqueue
  after_update_commit :broadcast_message_update_if_published
  after_update_commit :enqueue_if_scheduled_for_changed
  after_destroy_commit :broadcast_message_destroy

 
  # Instance Methods

  def edited?
    edited_at.present?
  end

  def deleted?
    deleted_at.present?
  end

  def published?
    published_at.present?
  end

  def publishable_now?
    scheduled_for.blank? || scheduled_for <= Time.current
  end

  def can_modify?(current_user)
    return false if deleted?
    current_user.admin? || user == current_user
  end

  def publish_now!
    return if published?

    broadcast_message
    update_column(:published_at, Time.current)
  end

  private

  def content_or_file_present
    cleaned_content = ActionView::Base.full_sanitizer.sanitize(content.to_s)
    if cleaned_content.blank? && !file.attached?
      errors.add(:base, "Message must have text or file")
    end
  end

  def parent_in_same_room
    return if parent.blank?
    return if parent.room_id == room_id

    errors.add(:parent_id, "must belong to the same room")
  end

  def scheduled_for_cannot_be_past
    return if scheduled_for.blank?
    return if scheduled_for >= 1.minute.ago

    errors.add(:scheduled_for, "cannot be in the past")
  end

  def scheduled_for_immutable_after_publish
    return unless published?
    return unless will_save_change_to_scheduled_for?
    return if scheduled_for_was == scheduled_for

    errors.add(:scheduled_for, "cannot be changed after publish")
  end

  def publish_or_enqueue
    publishable_now? ? publish_now! : enqueue_delivery
  end

  def enqueue_if_scheduled_for_changed
    return unless saved_change_to_scheduled_for?
    return if published?
    return unless scheduled_for.present? && scheduled_for > Time.current

    enqueue_delivery
  end

  def enqueue_delivery
    SendScheduledMessageJob.set(wait_until: scheduled_for).perform_later(id)
  end

  def broadcast_message
    target = parent_id.present? ? ActionView::RecordIdentifier.dom_id(parent, :replies) : "messages"

    broadcast_append_to room,
      target: target,
      partial: "messages/message",
      locals: { message: self }
  end

  def broadcast_message_update_if_published
    return unless published?

    broadcast_replace_to room,
      target: ActionView::RecordIdentifier.dom_id(self),
      partial: "messages/message",
      locals: { message: self }
  end

  def broadcast_message_destroy
    return unless published?

    broadcast_remove_to room, target: ActionView::RecordIdentifier.dom_id(self)
  end
end
