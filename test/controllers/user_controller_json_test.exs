defmodule ReactiveServer.UserControllerJsonTest do
  use ReactiveServer.ConnCase
  
  @moduletag :user_controller_json
  
  @unauthorized_error Poison.encode! %{:message =>  "Unauthorized access, please authorize your connection first", :error => "Forbidden", :code => 403}
  
  test "should respond with unauthorized if no login" do
    user = Repo.insert! %User{}    
    [:index, :new, :create, {:show, user}, {:show, user}, {:show, user}]
      |> Enum.each(fn params -> 
       conn = case params do
        {page, param} ->  conn = conn() |> get("/api" <> user_path(conn, page, param))
         page ->  conn = conn() |> get("/api" <> user_path(conn, page))
       end
    assert conn.status == 403
    assert conn.resp_body == @unauthorized_error    
    end)
  end
  
  test "should return unauthorized if token is not valid" do
      user = Repo.insert! %User{}
      conn = conn() 
        |> put_req_header("authorization", "Bearer " <> "IAmNotAValidToken")
        |> get("/api" <> user_path(conn, :show, user))
    assert conn.status == 403
    assert conn.resp_body == @unauthorized_error    
  end
  
  test "should return a user when requesting a resource", %{jwt: jwt} do
      user = Repo.insert! %User{}
      conn = conn() 
        |> put_req_header("authorization", "Bearer " <> jwt)
        |> get("/api" <> user_path(conn, :show, user))
      assert json_response(conn, 200) == Poison.encode!(Repo.get(User, user.id))
  end
  
  test "should return all users when requesting them", %{jwt: jwt} do
      Repo.insert! %User{}
      conn = conn() 
        |> put_req_header("authorization", "Bearer " <> jwt)
        |> get("/api" <> user_path(conn, :index))
      assert json_response(conn, 200) == Poison.encode!(Repo.all(User))
  end
end
