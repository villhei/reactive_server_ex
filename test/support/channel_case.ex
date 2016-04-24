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
      
      import ReactiveServer.TestCommon, only: [get_user: 0, get_jwt: 1, login: 1]

      # The default endpoint for testing
      @endpoint ReactiveServer.Endpoint
            
      setup do
        
        user = get_user()
        jwt = get_jwt(user)
        
        {:ok, socket} = connect(UserSocket, %{})
        {:ok, _, socket} = subscribe_and_join(socket, ReactiveServer.RoomChannel, "room:lobby", %{"guardian_token" => "#{jwt}"})
        {:ok, user: get_user, socket: socket}
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
