defmodule ReactiveServer.UserView do
  use ReactiveServer.Web, :view
  
  def render("show.json",  %{user: user}) do
    Poison.encode!(user)
  end
  
  def render("index.json", %{users: users}) do
    Poison.encode!(users)
  end
end
