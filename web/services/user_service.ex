defmodule ReactiveServer.UserService do
  use ReactiveServer.Web, :service

  alias ReactiveServer.User
  alias ReactiveServer.UserQuery

  defp remove_secrets(user) do
    Map.drop(user, [:passhash, :salt])
  end

  def email_address_in_use?(nil), do: false

  def email_address_in_use?(email_address) do
    existing_user = Repo.one(UserQuery.by_email(email_address))
    existing_user != nil
  end
  
  def get_users do 
    Repo.all(UserQuery.order_by_email)
      |> Enum.map(fn(user) -> remove_secrets(user) end)
  end
  
  def get_user(id) do
    remove_secrets(Repo.get!(User, id))
  end

  def create(changeset) do
    if changeset.valid? do
      {:ok, user} = Repo.insert(changeset)
    else
      {:error, changeset}
    end
  end
  
  # Here we use delete! (with a bang) because we expect
  # it to always work (and if it does not, it will raise).
  def delete!(id) do
    user = Repo.get!(User, id)
    Repo.delete!(user)
  end
end