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
end
