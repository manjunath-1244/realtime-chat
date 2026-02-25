class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_many :message_reads
  has_many :message_reactions
  has_one :attachment

  has_one_attached :file
  validate :content_or_file_present

  scope :pinned, -> { where(pinned: true) }
  
  def content_or_file_present
    if content.blank? && !file.attached?
      errors.add(:base, "Message must have text or file")
    end
  end

  after_create_commit -> {
    broadcast_append_to room,
      target: "messages",
      partial: "messages/message",
      locals: { message: self }
  }
end