defmodule ReactiveServer.RoomChannelTest do
  use ReactiveServer.ChannelCase
    
  alias ReactiveServer.RoomChannel
  
  @moduletag :room_channel_test
  
  test "room channel should require authentication" do
    {:ok, socket} = connect(UserSocket, %{})
    resp = subscribe_and_join(socket, RoomChannel, "room:lobby")
    assert {:error, %{reason: :authentication_required}} == resp
  end
  
  test "should return ok when authentication is provided", %{user: user} do
    {:ok, jwt, _} = Guardian.encode_and_sign(user)
    {:ok, socket} = connect(UserSocket, %{})
    resp = subscribe_and_join(socket, RoomChannel, "room:lobby", %{"guardian_token" => "#{jwt}"})
    assert {:ok, %{history: _}, _ } = resp
  end
  
  test "shout broadcasts to room:lobby", %{socket: socket} do
    push socket, "message", %{"body" => "hey there"}
    assert_broadcast "message", %{:message => "hey there", :sender => "abc", :timestamp => _}
  end
end