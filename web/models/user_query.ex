defmodule ReactiveServer.UserQuery do
  import Ecto.Query
  alias ReactiveServer.User

  def by_email(email) do
    from u in User, where: u.email == ^email
  end

  def order_by_email do
  	from u in User, order_by: u.email
  end
end