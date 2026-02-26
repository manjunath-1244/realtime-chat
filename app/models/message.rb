class Message < ApplicationRecord
  # =========================
  # Associations
  # =========================
  belongs_to :user
  belongs_to :room

  belongs_to :parent, class_name: "Message", optional: true
  has_many :replies,
           -> { order(:created_at) },
           class_name: "Message",
           foreign_key: :parent_id,
           dependent: :destroy

  has_many :message_reads, dependent: :destroy
  has_many :message_reactions, dependent: :destroy

  has_one_attached :file

  # =========================
  # Scopes
  # =========================
  scope :active, -> { where(deleted_at: nil) }
  scope :pinned, -> { where(pinned: true) }
  scope :top_level, -> { where(parent_id: nil) }

  # =========================
  # Validations
  # =========================
  validate :content_or_file_present
  validate :parent_in_same_room

  # =========================
  # Callbacks
  # =========================
  after_create_commit :broadcast_message
  after_update_commit :broadcast_message_update
  after_destroy_commit :broadcast_message_destroy

  # =========================
  # Instance Methods
  # =========================
  def edited?
    edited_at.present?
  end

  def deleted?
    deleted_at.present?
  end

  def can_modify?(current_user)
    return false if deleted?
    current_user.admin? || user == current_user
  end

  private

  def content_or_file_present
    if content.blank? && !file.attached?
      errors.add(:base, "Message must have text or file")
    end
  end

  def parent_in_same_room
    return if parent.blank?
    return if parent.room_id == room_id

    errors.add(:parent_id, "must belong to the same room")
  end

  def broadcast_message
    target = parent_id.present? ? ActionView::RecordIdentifier.dom_id(parent, :replies) : "messages"

    broadcast_append_to room,
      target: target,
      partial: "messages/message",
      locals: { message: self }
  end

  def broadcast_message_update
    broadcast_replace_to room,
      target: ActionView::RecordIdentifier.dom_id(self),
      partial: "messages/message",
      locals: { message: self }
  end

  def broadcast_message_destroy
    broadcast_remove_to room, target: ActionView::RecordIdentifier.dom_id(self)
  end
end
