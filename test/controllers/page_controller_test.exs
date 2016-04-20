defmodule ReactiveServer.PageControllerTest do
  use ExUnit.Case
  use ReactiveServer.ConnCase
  
  import Phoenix.View

  @moduletag :page_controller
  
  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ render_to_string(ReactiveServer.PageView, "index.html", [conn: conn, current_user: nil]) 
  end
end
