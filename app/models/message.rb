class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_many :message_reads
  has_many :message_reactions
  has_one :attachment

  validates :content, presence: true

  after_create_commit -> {
    broadcast_append_to room,
      target: "messages",
      partial: "messages/message",
      locals: { message: self }
  }
end