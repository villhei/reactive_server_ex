defmodule ReactiveServer.SessionControllerTest do
  use ExUnit.Case
  use ReactiveServer.ConnCase

  @valid_login %{email: "abc@abc.com", password: "password"}
  @invalid_login %{email: "abc@abc.com", password: "passwrod"}

  @moduletag :session_controller
  
  test "GET /login" do
    conn = get conn(), "/login"
    assert html_response(conn, 200) =~ "<h2>Login</h2>" 
  end

  test "POST /login makes a succesful login", %{user: user} do
    conn = conn() 
      |> post("/login", user: @valid_login)
    assert get_flash(conn, :error) == nil
    assert get_flash(conn, :info) == "User logged in"
    assert redirected_to(conn) == user_path(conn, :index)
    assert conn 
     |> fetch_session 
     |> get_session(:current_user) == user.id
  end
  
  test "POST /login makes a succesful login" do
    conn = conn() 
      |> post("/login", user: @invalid_login)
    assert get_flash(conn, :error) == "Invalid login"
    assert conn 
     |> fetch_session 
     |> get_session(:current_user) == nil
  end
  
  test "GET /logout makes a succesful logout" do
    conn = conn() 
      |> get("/logout")
    assert get_flash(conn, :info) == "Logged out"
    assert conn 
     |> fetch_session 
     |> get_session(:current_user) == nil
    assert redirected_to(conn) == page_path(conn, :index)
  end
end
