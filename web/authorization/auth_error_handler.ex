defmodule ReactiveServer.AuthErrorHandler do
	use ReactiveServer.Web, :controller

	def unauthenticated(conn, _params) do
		conn 
    |> put_flash(:error, "Unauthorized access")
    |> redirect(to: page_path(conn, :index))
  end
end