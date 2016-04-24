defmodule ReactiveServer.TestCommon do
  
  alias ReactiveServer.Repo
  alias ReactiveServer.User
  
  import Plug.Conn
  
  @session Plug.Session.init(
    store: :cookie,
    key: "_app",
    encryption_salt: "yadayada",
    signing_salt: "yadayada"
  )

  def get_user do
    %User{
    id: 123456,
    displayname: "abc",
    email: "abc@abc.com",
    passhash: Comeonin.Bcrypt.hashpwsalt("password")
    } |> Repo.insert
    Repo.get(User, 123456)
  end
  
  def login(conn) do
    conn 
      |> Plug.Session.call(@session)
      |> fetch_session
      |> put_session(:current_user, 123456)
      |> Guardian.Plug.sign_in(Repo.get(User, 123456), :token)
  end
  
  def get_jwt(user) do
    {:ok, jwt, _ } = Guardian.encode_and_sign(user)
    jwt
  end
  
end