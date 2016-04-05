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


  def create(changeset) do
    if changeset.valid? do
      {:ok, user} = Repo.insert(changeset)
    else
      {:error, changeset}
    end
  end
end