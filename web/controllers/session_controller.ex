defmodule ReactiveServer.SessionController do
  use ReactiveServer.Web, :controller
  alias ReactiveServer.User
  alias ReactiveServer.UserQuery

  def login_page(conn, params, current_user, _claims) do
    if(current_user) do
      conn |> redirect(to: page_path(conn, :index))
    else
      changeset = User.login_changeset(%User{})
      render(conn, ReactiveServer.SessionView, "login.html", changeset: changeset)
    end
  end

  def login(conn, params, _current_user, _claims) do
    user = Repo.one(UserQuery.by_email(params["user"]["email"] || ""))
    if user do
      changeset = User.login_changeset(user, params["user"])
      if changeset.valid? do
        conn
          |> put_flash(:info, "User logged in")
          |> put_session(:current_user, user.id)
          |> Guardian.Plug.sign_in(user, :token)
          |> redirect(to: user_path(conn, :index))
      else
        conn
          |> put_status(401)
          |> put_session(:error, "Invalid login information")
          |> render("login.html", changeset: changeset)
      end
    else
      changeset = User.login_changeset(%User{})
      |> Ecto.Changeset.add_error(:login, "incorrect")
      conn 
        |> put_status(401)
        |> put_flash(:error, "Invalid login")
        |> render(conn, "login.html", changeset: changeset)
    end
  end

  def logout(conn, _params, current_user, _claims) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "Logged out")
    |> redirect(to: page_path(conn, :index))
  end
  
  def unauthenticated(%{path_info: ["api" | _ ] } = conn, _params) do
		IO.inspect(conn)
    IO.inspect("Trying the json response")
    conn 
    |> put_view(ReactiveServer.ErrorView)
    |> put_status(403)
    |> render("403.json")
  end
  
	def unauthenticated(conn, _params) do
		IO.inspect(conn)
    conn 
    |> put_flash(:error, "Unauthorized access")
    |> redirect(to: page_path(conn, :index))
  end
 
end