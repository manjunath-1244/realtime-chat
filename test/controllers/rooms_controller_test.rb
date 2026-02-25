require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "show filters messages by query" do
    user = User.create!(
      email: "searcher@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
    room = Room.create!(name: "Search Room", room_type: "group", created_by: user.id)
    RoomMember.create!(room: room, user: user, role: "member", joined_at: Time.current)

    Message.create!(room: room, user: user, content: "hello apples", message_type: "text")
    Message.create!(room: room, user: user, content: "goodbye oranges", message_type: "text")

    sign_in user
    get room_path(room), params: { query: "apple" }

    assert_response :success
    assert_includes response.body, "hello apples"
    assert_not_includes response.body, "goodbye oranges"
  end
end
