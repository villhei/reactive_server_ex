defmodule ReactiveServer.ErrorViewTest do
  use ReactiveServer.ConnCase, async: true
  
  @moduletag :error_view_case

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html", %{conn: conn} do
    assert render_to_string(ReactiveServer.ErrorView, "404.html", [conn: conn]) 
    |> String.contains?("Sorry, the page you are looking for does not exist.")
  end

  test "render 500.html", %{conn: conn} do
    assert render_to_string(ReactiveServer.ErrorView, "500.html", [conn: conn])
    |> String.contains?("Server internal error")
  end

  test "render any other", %{conn: conn} do
    assert render_to_string(ReactiveServer.ErrorView, "505.html", [conn: conn])
    |> String.contains?("Server internal error")
  end
end
