defmodule ReactiveServer.ErrorView do
  import ReactiveServer.Router.Helpers
  use ReactiveServer.Web, :view
  
  def render("403.json", assigns) do
    %{
      error: "Forbidden",
      code: 403,
      message: "Unauthorized access, please authorize your connection first"
    }
  end

  def render("404.html", assigns) do
    render("not_found.html", assigns)
  end

  def render("500.html", _assigns) do
    "Server internal error"
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
