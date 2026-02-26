class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room
  before_action :authorize_room_access!
  before_action :set_message, only: [:edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]
  
  def create
    parent_message = nil
    if message_params[:parent_id].present?
      parent_message = @room.messages.active.find_by(id: message_params[:parent_id])
      unless parent_message
        redirect_to @room, alert: "Invalid reply target"
        return
      end
    end

    @message = @room.messages.build(message_params.except(:parent_id))
    @message.user = current_user
    @message.parent = parent_message if parent_message

    if @message.save
      log_message_create(@message)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "new_message",
              partial: "messages/form",
              locals: { room: @room, message: Message.new }
            )
          ]
        end

        format.html { redirect_to @room }
      end
    else
      redirect_to @room, alert: "Message cannot be blank"
    end
  end

  def edit
    if @message.deleted?
      redirect_to @message.room, alert: "Deleted messages cannot be edited"
      return
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @message.room }
    end
  end

  def update
    if @message.deleted?
      redirect_to @message.room, alert: "Deleted messages cannot be edited"
      return
    end

    before_values = {
      content: @message.content,
      message_type: @message.message_type,
      scheduled_for: @message.scheduled_for
    }

    if @message.update(message_params.merge(edited_at: Time.current))
      log_message_update(@message, before_values)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @message.room, notice: "Message updated" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render :edit, status: :unprocessable_entity
        end
        format.html { redirect_to @message.room, alert: @message.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    deleted_message = @message
    delete_snapshot = {
      content: deleted_message.content,
      message_type: deleted_message.message_type,
      parent_id: deleted_message.parent_id,
      scheduled_for: deleted_message.scheduled_for,
      published_at: deleted_message.published_at
    }

    @message.destroy
    log_message_delete(deleted_message, delete_snapshot)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @message.room, notice: "Message deleted" }
    end
  end


  def pin
    @message = @room.messages.find(params[:id])
    previously_pinned = @room.messages.find_by(pinned: true)

    # Unpin all other messages
    @room.messages.update_all(pinned: false)

    # Pin selected message
    @message.update(pinned: true)
    log_message_pin(@message, previously_pinned)

    redirect_to @room, notice: "Message pinned successfully"
  end

  private

  def set_room
    @room = Room.find(params[:room_id])
  end

  def set_message
    @message = @room.messages.find(params[:id])
  end

  def authorize_room_access!
    return if @room.users.include?(current_user)

    redirect_to rooms_path, alert: "Access denied"
  end

  def authorize_user!
    unless @message.can_modify?(current_user)
      redirect_to room_path(@message.room), alert: "Not authorized"
    end
  end

  def message_params
    params.require(:message).permit(:content, :message_type, :file, :parent_id, :scheduled_for)
  end

  def log_message_create(message)
    if message.scheduled_for.present? && !message.published?
      event_type = "message_scheduled"
    elsif message.parent_id.present?
      event_type = "message_replied"
    else
      event_type = "message_created"
    end

    create_audit_log!(
      event_type: event_type,
      auditable: message,
      metadata: {
        parent_id: message.parent_id,
        message_type: message.message_type,
        scheduled_for: message.scheduled_for,
        published_at: message.published_at
      }
    )
  end

  def log_message_update(message, before_values)
    create_audit_log!(
      event_type: "message_updated",
      auditable: message,
      metadata: {
        before: before_values,
        after: {
          content: message.content,
          message_type: message.message_type,
          scheduled_for: message.scheduled_for,
          edited_at: message.edited_at
        }
      }
    )
  end

  def log_message_delete(message, snapshot)
    create_audit_log!(
      event_type: "message_deleted",
      auditable_type: "Message",
      auditable_id: message.id,
      metadata: { before: snapshot }
    )
  end

  def log_message_pin(message, previously_pinned)
    create_audit_log!(
      event_type: "message_pinned",
      auditable: message,
      metadata: {
        previous_pinned_message_id: previously_pinned&.id,
        current_pinned_message_id: message.id
      }
    )
  end

  def create_audit_log!(event_type:, metadata:, auditable: nil, auditable_type: nil, auditable_id: nil)
    AuditLog.create!(
      user: current_user,
      room: @room,
      event_type: event_type,
      auditable: auditable,
      auditable_type: auditable_type,
      auditable_id: auditable_id,
      metadata: metadata
    )
  rescue StandardError => e
    Rails.logger.error("AuditLog write failed: #{e.class} - #{e.message}")
  end
end
