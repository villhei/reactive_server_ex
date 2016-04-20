defmodule ReactiveServer.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
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
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias ReactiveServer.Repo
      alias ReactiveServer.User
      
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]

      import ReactiveServer.Router.Helpers

      # The default endpoint for testing
      @endpoint ReactiveServer.Endpoint
      
      import Plug.Conn
      
      @session Plug.Session.init(
        store: :cookie,
        key: "_app",
        encryption_salt: "yadayada",
        signing_salt: "yadayada"
      )

      setup do
        %User{
          id: 123456,
          displayname: "abc",
          email: "abc@gmail.com",
          password: Comeonin.Bcrypt.hashpwsalt("password")
        } |> Repo.insert
        {:ok, user: Repo.get(User, 123456) }
      end

      def login(user) do
        conn 
          |> Plug.Session.call(@session)
          |> fetch_session
          |> Guardian.Plug.sign_in(Repo.get(User, 123456), :token)
      end
    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(ReactiveServer.Repo, [])
    end

    {:ok, conn: Phoenix.ConnTest.conn()}
  end
end
