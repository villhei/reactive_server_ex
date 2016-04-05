defmodule ReactiveServer.User do
  use ReactiveServer.Web, :model

  alias ReactiveServer.Repo

  schema "users" do
    field :email, :string
    field :displayname, :string
    field :firstname, :string
    field :lastname, :string
    field :passhash, :string
    field :password, :string, virtual: true
    field :bio, :string

    timestamps
  end

  @required_fields ~w(email displayname password)
  @required_fields_login ~w(email password)
  @required_fields_update ~w()

  @optional_fields ~w(firstname lastname bio)
  @optional_fields_update ~w(email firstname lastname bio password)


  def from_email(nil), do: { :error, :not_found }
  def from_email(email) do
    Repo.one(User, email: email)
  end

  def create_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> maybe_update_password
  end

  def update_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields_update, @optional_fields_update)
    |> maybe_update_password
  end

  def login_changeset(model), do: model |> cast(%{}, ~w(), @required_fields_login)

  def login_changeset(model, params) do
    model
    |> cast(params, ~w(email password), ~w())
    |> validate_password
  end

  def valid_password?(nil, _), do: false
  def valid_password?(_, nil), do: false
  def valid_password?(password, crypted), do: Comeonin.Bcrypt.checkpw(password, crypted)

  defp maybe_update_password(changeset) do
    case Ecto.Changeset.fetch_change(changeset, :password) do
      {:ok, password} ->
        changeset
        |> Ecto.Changeset.put_change(:passhash, Comeonin.Bcrypt.hashpwsalt(password))
        :error -> changeset
    end
  end

  defp validate_password(changeset) do
    case Ecto.Changeset.get_field(changeset, :passhash) do
      nil -> password_incorrect_error(changeset)
      crypted -> validate_password(changeset, crypted)
    end
  end

  defp validate_password(changeset, crypted) do
    password = Ecto.Changeset.get_change(changeset, :password)
    if valid_password?(password, crypted), do: changeset, else: password_incorrect_error(changeset)
  end

  defp password_incorrect_error(changeset), do: Ecto.Changeset.add_error(changeset, :password, "is incorrect")
  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
