defmodule ReactiveServer.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :displayname, :string
      add :firstname, :string
      add :lastname, :string
      add :salt, :string
      add :passhash, :string
      add :bio, :string

      timestamps
    end

  end
end
