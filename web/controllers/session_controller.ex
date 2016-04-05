defmodule ReactiveServer.SessionController do
  use ReactiveServer.Web, :controller
  alias ReactiveServer.User
  alias ReactiveServer.UserQuery

  def login_page(conn, params, current_user, _claims) do
    if(current_user) do
      conn |> redirect(to: page_path(conn, :index))
    else
      changeset = User.login_changeset(%User{})
      render(conn, ReactiveServer.SessionView, "login.html", current_user: nil, changeset: changeset)
    end
  end

  def login(conn, params = %{}, current_user, _claims) do
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
        render(conn, "login.html", current_user: current_user, changeset: changeset)
      end
    else
      changeset = User.login_changeset(%User{})
      |> Ecto.Changeset.add_error(:login, "incorrect")
      render(conn, "login.html", current_user: current_user, changeset: changeset)
    end
  end

  def logout(conn, _params, current_user, _claims) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "Logged out.")
    |> redirect(to: page_path(conn, :index))
  end
end