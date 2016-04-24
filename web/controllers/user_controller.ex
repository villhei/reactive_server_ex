defmodule ReactiveServer.UserController do
  use ReactiveServer.Web, :controller

  alias ReactiveServer.User
  alias ReactiveServer.UserQuery
  alias ReactiveServer.UserService

  # https://hexdocs.pm/phoenix/Phoenix.Controller.Pipeline.html#summary
  plug Guardian.Plug.EnsureAuthenticated, handler: ReactiveServer.SessionController

  # Scrub empty params to cause validation errors
  plug :scrub_params, "user" when action in [:create, :update]


  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "Authentication required")
    |> redirect(to: session_path(conn, :login_page))
  end

  def index(conn, _params, _current_user, _claims) do
    render(conn, :index, users: UserService.get_users)
  end

  def new(conn, _params, _current_user, _claims) do
    changeset = User.changeset(%User{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params} = params, _current_user, _claims) do
    email = user_params["email"] || nil
    changeset = User.create_changeset(%User{}, user_params)

    case UserService.email_address_in_use?(email) do
      true -> conn
        |> put_flash(:error, "An user exists with the given email address")
        |> render(:new, changeset: changeset)
      false -> do_create(conn, params, changeset)
    end 
  end

  defp do_create(conn, _params, changeset) do
    case UserService.create(changeset) do
      {:ok, _user} -> 
        conn |> put_flash(:info, "User created")
             |> redirect(to: user_path(conn, :index))
      {:error, changeset} -> 
        conn |> put_flash(:error, "Error creating user")
             |> render(:new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _current_user, _claims) do
    user = UserService.get_user(id)
    render(conn, :show,  user: user)
  end

  def edit(conn, %{"id" => id}, _current_user, _claims) do
    user = UserService.get_user(id)
    changeset = User.changeset(user)
    render(conn, :edit, user: user, changeset: changeset)
  end
  
  defp email_address_in_use?(nil), do: false

  defp email_address_in_use?(email_address) do
    existing_user = Repo.one(UserQuery.by_email(email_address))
    existing_user != nil
  end

  def update(conn, %{"id" => id, "user" => user_params} = params, _current_user, _claims) do
    user = UserService.get_user(id)
    changeset = User.update_changeset(user, user_params)
    email = Ecto.Changeset.get_change(changeset, :email, nil)
    case email_address_in_use?(email) do
      false -> do_update(conn, params, changeset)
      true -> conn
      |> put_flash(:error, "An user exists with the given email address")
      |> render(:edit, user: user, changeset: changeset) 
    end 
  end

  defp do_update(conn, %{"id" => id}, changeset) do
    user = UserService.get_user(id)
    if changeset.valid? do
      Repo.update(changeset)
      conn
      |> put_flash(:info, "User updated successfully.")
      |> redirect(to: user_path(conn, :index))
    else
      render(conn, :edit, user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, _current_user, _claims) do
    UserService.delete!(id)
    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end
end
