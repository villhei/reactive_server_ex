defmodule ReactiveServer.UserControllerTest do
  use ReactiveServer.ConnCase
import Plug.Conn
  alias ReactiveServer.User
  @valid_attrs %{bio: "some content", displayname: "some content", email: "foo@foo.com", firstname: "some content", lastname: "some content", password: "foo"}
  @valid_query_attrs %{bio: "some content", displayname: "some content", email: "foo@foo.com", firstname: "some content", lastname: "some content"}
  @invalid_attrs %{}
  
  @session Plug.Session.init(
    store: :cookie,
    key: "_app",
    encryption_salt: "yadayada",
    signing_salt: "yadayada"
  )

  setup do
    %User{
      id: 123456,
      displayname: "abc",
      email: "abc@gmail.com",
      password: Comeonin.Bcrypt.hashpwsalt("password")
    } |> Repo.insert
    {:ok, user: Repo.get(User, 123456) }
  end

  @moduletag :user_controller
  
  def login(conn, user) do
    conn 
      |> Plug.Session.call(@session)
      |> fetch_session
      |> Guardian.Plug.sign_in(user, :token)
  end
  
  test "unauthenticated should be redirected", %{} do
    conn = get conn, user_path(conn, :index)
    assert redirected_to(conn) =~ "/"
  end

  test "lists all entries on index", %{user: user} do
    conn = conn() 
      |> login(user) 
      |> get(user_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing users"
  end

  test "renders form for new resources", %{user: user} do
    conn = conn() 
      |> login(user) 
      |> get(user_path(conn, :new))
    assert html_response(conn, 200) =~ "New user"
  end

  test "creates resource and redirects when data is valid", %{user: user} do
    conn = conn() 
      |> login(user) 
      |> post(user_path(conn, :create), user: @valid_attrs)
    assert get_flash(conn, :error) == nil
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, @valid_query_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{user: user} do
    conn = conn() 
      |> login(user) 
      |> post(user_path(conn, :create), user: @invalid_attrs)    
    assert html_response(conn, 200) =~ "New user"
  end

  test "shows chosen resource" do
    user = Repo.insert! %User{}
    conn = conn() 
      |> login(user) 
      |> get(user_path(conn, :show, user))
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent", %{user: user} do
    assert_error_sent 404, fn ->
      conn() 
        |> login(user) 
        |> get(user_path(conn, :show, -1))
    end
  end

  test "renders form for editing chosen resource"do
    user = Repo.insert! %User{}
    conn = conn() 
      |> login(user) 
      |> get(user_path(conn, :edit, user))
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "updates chosen resource and redirects when data is valid" do
    user = Repo.insert! %User{}
    conn = conn() 
      |> login(user) 
      |> put(user_path(conn, :update, user), user: @valid_attrs)
      
    assert redirected_to(conn) == user_path(conn, :index)
    assert get_flash(conn, :info) == "User updated successfully."
    assert Repo.get_by(User, @valid_query_attrs)
  end

  test "does not update chosen resource and redirects when data is empty" do
    user = Repo.insert! %User{}
    conn = conn() 
      |> login(user) 
      |>put(user_path(conn, :update, user), user: @invalid_attrs)
    assert redirected_to(conn) == user_path(conn, :index)
  end

  test "deletes chosen resource" do
    user = Repo.insert! %User{}
    conn = conn() 
      |> login(user) 
      |> delete(user_path(conn, :delete, user))
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end
end
