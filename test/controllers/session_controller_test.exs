defmodule ReactiveServer.SessionControllerTest do
  use ExUnit.Case
  use ReactiveServer.ConnCase

  @valid_login %{email: "abc@abc.com", password: "password"}
  @invalid_login %{email: "abc@abc.com", password: "passwrod"}
  
  @unauthorized_error Poison.encode! %{message: "Unauthorized login credentials", error: "Unauthorized", code: 401}
  @logout_message Poison.encode! %{code: 200, message: "Logged out"}
  
  @moduletag :session_controller
  
  test "GET /login" do
    conn = get conn(), "/login"
    assert html_response(conn, 200) =~ "<h2>Login</h2>" 
  end

  test "POST /login returns an invalid login with wrong credentials" do
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
  
  # JSON Api

  test "POST /api/login makes a succesful login", %{jwt: jwt} do
    
    valid_response = %{code: 200, message: "Login succesful" }
    conn = conn() 
      |> put_req_header("content-type", "application/json")
      |> post("/api/login", Poison.encode!(@valid_login))
    assert conn.status == 200
    response = Poison.decode!(conn.resp_body)
    assert Map.get(response, "code") == 200
    assert Map.get(response, "message") == "Login succesful"
    assert String.length(Map.get(response, "jwt_token")) > 0
  end
    
  test "POST to /api/login with invalid credentials returns an error" do
    conn = conn() 
      |> post("/api/login", @invalid_login)   
    assert conn.status == 401
    assert conn.resp_body == @unauthorized_error    
  end
  
  test "GET to /api/login returns a not found" do
    conn = conn() 
      |> get("/api/login")   
    assert conn.status == 404
  end
end
