defmodule ReactiveServer.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      use Phoenix.ChannelTest

      alias ReactiveServer.Repo
      alias ReactiveServer.User
      alias ReactiveServer.UserSocket
      
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]

      # The default endpoint for testing
      @endpoint ReactiveServer.Endpoint
            
      setup do
        %User{
          id: 123456,
          displayname: "abc",
          email: "abc@abc.com",
          passhash: Comeonin.Bcrypt.hashpwsalt("password")
        } |> Repo.insert
        
        user = Repo.get(User, 123456)
        
        {:ok, jwt, _ } = Guardian.encode_and_sign(user)
        {:ok, socket} = connect(UserSocket, %{})
        {:ok, _, socket} = subscribe_and_join(socket, ReactiveServer.RoomChannel, "room:lobby", %{"guardian_token" => "#{jwt}"})
        {:ok, user: user, socket: socket}
      end
      
    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(ReactiveServer.Repo, [])
    end

    :ok
  end
end
