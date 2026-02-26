class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :room, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  validates :event_type, presence: true
end
