defmodule ReactiveServer.ViewHelpers do
  def active_on_current(%{request_path: path}, path), do: "active"
  def active_on_current(_, _), do: ""

  def admin_logged_in?(conn), do: Guardian.Plug.authenticated?(conn, :admin)
  def admin_user(conn), do: Guardian.Plug.current_resource(conn, :admin)

  def logged_in?(conn), do: Guardian.Plug.authenticated?(conn)

  def current_user(conn) do
   		user = Guardian.Plug.current_resource(conn)
   		IO.puts("\n\n\n***\n\n")
   		IO.inspect(user)
	end

  def active_path(conn, path) do
    current_path = Path.join(["/" | conn.path_info])
    if path == current_path do
      "active"
    else
      nil
    end
  end
end