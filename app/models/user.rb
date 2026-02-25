class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :room_members
  has_many :rooms, through: :room_members
  has_many :messages
  has_many :message_reads
  has_many :message_reactions
  has_many :notifications

  enum role: { user: 0, admin: 1 }
end
