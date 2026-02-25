class RoomChannel < ApplicationCable::Channel
  def subscribed
    room = Room.find(params[:room_id])

    if room.users.include?(current_user)
      stream_for room
    else
      reject
    end
  end
end