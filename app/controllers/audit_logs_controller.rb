class AuditLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @audit_logs = AuditLog
      .includes(:user, :room)
      .order(created_at: :desc)
      .limit(500)
  end

  private

  def authorize_admin!
    return if current_user.admin?

    redirect_to rooms_path, alert: "Only admins can view audit logs."
  end
end
