ExUnit.start

Mix.Task.run "ecto.create", ~w(-r ReactiveServer.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r ReactiveServer.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(ReactiveServer.Repo)

