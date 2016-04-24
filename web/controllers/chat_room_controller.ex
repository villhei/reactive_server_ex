defmodule ReactiveServer.ChatRoomController do
  use ReactiveServer.Web, :controller

  alias ReactiveServer.ChatRoom
  
    # https://hexdocs.pm/phoenix/Phoenix.Controller.Pipeline.html#summary
  plug Guardian.Plug.EnsureAuthenticated, handler: ReactiveServer.SessionController
  plug ReactiveServer.Plug.CurrentUser

  plug :scrub_params, "chat_room" when action in [:create, :update]

  def index(conn, _params, _current_user, _claims) do
    chatrooms = Repo.all(ChatRoom)
    render(conn, "index.html", chatrooms: chatrooms, )
  end

  def new(conn, _params, _current_user, _claims) do
    changeset = ChatRoom.changeset(%ChatRoom{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"chat_room" => chat_room_params}, _current_user, _claims) do
    changeset = ChatRoom.changeset(%ChatRoom{}, chat_room_params)

    case Repo.insert(changeset) do
      {:ok, _chat_room} ->
        conn
        |> put_flash(:info, "Chat room created successfully.")
        |> redirect(to: chat_room_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _current_user, _claims) do
    chat_room = Repo.get!(ChatRoom, id)
    render(conn, "show.html", chat_room: chat_room)
  end

  def edit(conn, %{"id" => id}, _current_user, _claims) do
    chat_room = Repo.get!(ChatRoom, id)
    changeset = ChatRoom.changeset(chat_room)
    render(conn, "edit.html", chat_room: chat_room, changeset: changeset)
  end

  def update(conn, %{"id" => id, "chat_room" => chat_room_params}, _current_user, _claims) do
    chat_room = Repo.get!(ChatRoom, id)
    changeset = ChatRoom.changeset(chat_room, chat_room_params)

    case Repo.update(changeset) do
      {:ok, chat_room} ->
        conn
        |> put_flash(:info, "Chat room updated successfully.")
        |> redirect(to: chat_room_path(conn, :show, chat_room))
      {:error, changeset} ->
        render(conn, "edit.html", chat_room: chat_room, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, _current_user, _claims) do
    chat_room = Repo.get!(ChatRoom, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(chat_room)

    conn
    |> put_flash(:info, "Chat room deleted successfully.")
    |> redirect(to: chat_room_path(conn, :index))
  end
end
