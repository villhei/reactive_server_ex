defmodule ReactiveServer.Plug.CurrentUser do
  import Plug.Conn

	def init(default), do: default

  def call(conn, _default) do
    current_user = get_session(conn, :current_user)
    assign(conn, :current_user, current_user)
  end
end