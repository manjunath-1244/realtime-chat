class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: [:show, :destroy]

  def index
    @rooms = current_user.rooms
  end

  def show
    unless @room.users.include?(current_user)
      redirect_to rooms_path, alert: "Access denied"
      return
    end

    @messages = @room.messages.includes(:user).order(:created_at)
    @message = Message.new
  end

  def new
    @room = Room.new
    @users = User.where.not(id: current_user.id)
  end

  def create
    @room = Room.new(room_params)
    @room.created_by = current_user.id

    if @room.save
      @room.room_members.create!(
        user: current_user,
        role: "admin",
        joined_at: Time.current
      )

      if params[:user_ids]
        params[:user_ids].each do |user_id|
          @room.room_members.create!(
            user_id: user_id,
            role: "member",
            joined_at: Time.current
          )
        end
      end

      redirect_to @room
    else
      render :new
    end
  end

  def destroy
    @room.destroy
    redirect_to rooms_path
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :room_type)
  end
end