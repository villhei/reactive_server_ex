defmodule ReactiveServer.PageController do
  use ReactiveServer.Web, :controller

  alias ReactiveServer.User
  alias ReactiveServer.UserQuery
  alias ReactiveServer.UserService

  def index(conn, _params, current_user, _claims) do
    conn 
    |> render("index.html", current_user: current_user, claims: _claims)
  end

  def signup(conn, _params, current_user, _claims) do
    changeset = User.changeset(%User{})
    render(conn, "signup.html", current_user: current_user, changeset: changeset)
  end

  def create(conn, %{"user" => user_params} = params, current_user, _claims) do
    email = user_params["email"] || nil
    changeset = User.create_changeset(%User{}, user_params)
    case UserService.email_address_in_use?(email) do
      true -> conn
        |> put_flash(:error, "The email address is in use, try logging in!")
        |> render("signup.html", changeset: changeset)
      false -> do_create(conn, params, current_user, changeset)
    end 
  end

  defp do_create(conn, %{"user" => user_params}, current_user, changeset) do
    case UserService.create(changeset) do
      {:ok, user} -> 
        conn  |> put_flash(:info, "User created")
              |> sign_in_if_needed(current_user, user)
              |> put_session(:current_user, user.id)
              |> redirect(to: page_path(conn, :index))
      {:error, changeset} -> 
        conn  |> render("signup.html", changeset: changeset,  current_user: current_user)
    end
  end


  defp sign_in_if_needed(conn, current_user, user) do
    if current_user == nil do
        conn |> Guardian.Plug.sign_in(user, :token)
      else
      conn
    end
  end
end
