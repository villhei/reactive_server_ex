defmodule ReactiveServer.UserTest do
  use ReactiveServer.ModelCase

  alias ReactiveServer.User

  @valid_attrs %{bio: "some content", displayname: "some content", email: "some content", firstname: "some content", lastname: "some content", passhash: "some content", salt: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
