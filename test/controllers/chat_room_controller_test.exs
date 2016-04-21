defmodule ReactiveServer.ChatRoomControllerTest do
  use ReactiveServer.ConnCase

  alias ReactiveServer.ChatRoom
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}
  
  @moduletag :chatroom_controller
  
  test "should redirect all pages if no login" do
    chat_room = Repo.insert! %ChatRoom{}    
    [:index, :new, :create, {:show, chat_room}, {:show, chat_room}, {:show, chat_room}]
      |> Enum.each(fn params -> 
       conn = case params do
        {page, param} -> conn = conn() |> get(chat_room_path(conn, page, param))
         page -> conn = conn() |> get(chat_room_path(conn, page))
       end
       assert redirected_to(conn) == "/"
    end)
  end

  test "lists all entries on index" do
    conn = conn() 
      |> login 
      |> get(chat_room_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing chatrooms"
  end

  test "renders form for new resources" do
    conn = conn() 
      |> login 
      |> get(chat_room_path(conn, :new))
    assert html_response(conn, 200) =~ "New chat room"
  end

  test "creates resource and redirects when data is valid" do
    conn = conn() 
      |> login 
      |> post(chat_room_path(conn, :create), chat_room: @valid_attrs)
    assert redirected_to(conn) == chat_room_path(conn, :index)
    assert Repo.get_by(ChatRoom, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid" do
    conn = conn() 
      |> login 
      |> post(chat_room_path(conn, :create), chat_room: @invalid_attrs)
    assert html_response(conn, 200) =~ "New chat room"
  end

  test "shows chosen resource" do
    chat_room = Repo.insert! %ChatRoom{}
    conn = conn() 
      |> login 
      |> get(chat_room_path(conn, :show, chat_room))
    assert html_response(conn, 200) =~ "Show chat room"
  end

  test "renders page not found when id is nonexistent" do
    assert_error_sent 404, fn ->
      conn()
        |> login
        |> get(chat_room_path(conn, :show, -1))
    end
  end

  test "renders form for editing chosen resource" do
    chat_room = Repo.insert! %ChatRoom{}
    conn = conn() 
      |> login 
      |> get(chat_room_path(conn, :edit, chat_room))
    assert html_response(conn, 200) =~ "Edit chat room"
  end

  test "updates chosen resource and redirects when data is valid" do
    chat_room = Repo.insert! %ChatRoom{}
    conn = conn() 
      |> login
      |> put(chat_room_path(conn, :update, chat_room), chat_room: @valid_attrs)
    assert redirected_to(conn) == chat_room_path(conn, :show, chat_room)
    assert Repo.get_by(ChatRoom, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid" do
    chat_room = Repo.insert! %ChatRoom{}
    conn = conn() 
      |> login
      |> put(chat_room_path(conn, :update, chat_room), chat_room: @invalid_attrs)
    assert html_response(conn, 200) =~ "Edit chat room"
  end

  test "deletes chosen resource" do
    chat_room = Repo.insert! %ChatRoom{}
    conn = conn()
      |> login
      |> delete(chat_room_path(conn, :delete, chat_room))
    assert redirected_to(conn) == chat_room_path(conn, :index)
    refute Repo.get(ChatRoom, chat_room.id)
  end
end
