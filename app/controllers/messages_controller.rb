
class MessagesController < ApplicationController
  before_action :authenticate_user!

 def create
  @room = Room.find(params[:room_id])
  return head :forbidden unless @room.users.include?(current_user)

  @message = @room.messages.build(message_params)
  @message.user = current_user

  if @message.save
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("new_message", 
            partial: "messages/form", 
            locals: { room: @room, message: Message.new })
        ]
      end

      format.html { redirect_to @room }
    end
  else
    redirect_to @room, alert: "Message cannot be blank"
  end
end

def destroy
  @room = Room.find(params[:room_id])
  @message = @room.messages.find(params[:id])

  if @message.user == current_user
    @message.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @room }
    end
  else
    redirect_to @room, alert: "Not authorized"
  end
end

  private

  def message_params
    params.require(:message).permit(:content, :message_type)
  end
end

