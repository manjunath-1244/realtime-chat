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

    if @message.update(message_params.merge(edited_at: Time.current))
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
    @message.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @message.room, notice: "Message deleted" }
    end
  end


  def pin
    @message = @room.messages.find(params[:id])

    # Unpin all other messages
    @room.messages.update_all(pinned: false)

    # Pin selected message
    @message.update(pinned: true)

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
    params.require(:message).permit(:content, :message_type, :file, :parent_id)
  end
end
