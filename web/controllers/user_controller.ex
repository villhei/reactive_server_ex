defmodule ReactiveServer.UserController do
  use ReactiveServer.Web, :controller

  alias ReactiveServer.User
  alias ReactiveServer.UserQuery
  alias ReactiveServer.UserService

  # https://hexdocs.pm/phoenix/Phoenix.Controller.Pipeline.html#summary
  plug Guardian.Plug.EnsureAuthenticated, handler: ReactiveServer.AuthErrorHandler

  # Scrub empty params to cause validation errors
  plug :scrub_params, "user" when action in [:create, :update]

  defp remove_secrets(user) do
    Map.drop(user, [:passhash, :salt])
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "Authentication required")
    |> redirect(to: login_path(conn, :login_page))
  end

  def index(conn, _params, current_user, _claims) do
    users = Repo.all(UserQuery.order_by_email)
    |> Enum.map(fn(user) -> remove_secrets(user) end)
    render(conn, "index.html", users: users, current_user: current_user)
  end

  def new(conn, _params, current_user, _claims) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", current_user: current_user, changeset: changeset)
  end

  def create(conn, %{"user" => user_params} = params, current_user, _claims) do
    email = user_params["email"] || nil
    changeset = User.create_changeset(%User{}, user_params)

    case UserService.email_address_in_use?(email) do
      true -> conn
        |> put_flash(:error, "An user exists with the given email address")
        |> render("new.html", changeset: changeset)
      false -> do_create(conn, params, current_user, changeset)
    end 
  end

  defp do_create(conn, %{"user" => user_params}, current_user, changeset) do
    case UserService.create(changeset) do
      {:ok, user} -> 
        conn  |> put_flash(:info, "User created")
              |> redirect(to: user_path(conn, :index))
      {:error, changeset} -> 
        conn  |> render("new.html", changeset: changeset,  current_user: current_user)
    end
  end

  defp sign_in_if_needed(conn, current_user, user) do
    if current_user == nil do
        conn |> Guardian.Plug.sign_in(user, :token)
      else
      conn
    end
  end

  def show(conn, %{"id" => id}, current_user, _claims) do
    user = Repo.get!(User, id)
    render(conn, "show.html", current_user: current_user, user: remove_secrets(user))
  end

  def edit(conn, %{"id" => id}, current_user, _claims) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, current_user: current_user, changeset: changeset)
  end
  
  defp email_address_in_use?(nil), do: false

  defp email_address_in_use?(email_address) do
    IO.inspect(email_address)
    existing_user = Repo.one(UserQuery.by_email(email_address))
    existing_user != nil
  end

  def update(conn, %{"id" => id, "user" => user_params} = params, current_user, _claims) do
    user = Repo.get!(User, id)
    changeset = User.update_changeset(user, user_params)
    email = Ecto.Changeset.get_change(changeset, :email, nil)
    case email_address_in_use?(email) do
      false -> do_update(conn, params, current_user, changeset)
      true -> conn
      |> put_flash(:error, "An user exists with the given email address")
      |> render("edit.html", current_user: current_user, user: remove_secrets(user), changeset: changeset) 
    end 
  end

  defp do_update(conn, %{"id" => id, "user" => user_params}, current_user, changeset) do
    user = Repo.get!(User, id)
    if changeset.valid? do
      Repo.update(changeset)
      conn
      |> put_flash(:info, "User updated successfully.")
      |> redirect(to: user_path(conn, :index))
    else
      render(conn, "edit.html", current_user: current_user, user: remove_secrets(user), changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user, _claims) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end
end
