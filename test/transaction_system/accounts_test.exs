defmodule TransactionSystem.AccountsTest do
  alias TransactionSystemWeb.Auth.Guardian
  use TransactionSystem.DataCase

  alias TransactionSystem.Accounts

  describe "users" do
    alias TransactionSystem.Accounts.User

    import TransactionSystem.AccountsFixtures

    @invalid_attrs %{
      balance: "invalid-balance",
      first_name: nil,
      last_name: nil,
      cpf: nil,
      password: nil,
    }

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        first_name: "John",
        last_name: "Doe",
        cpf: "000.000.000-00",
        password: "password",
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.balance == 0
      assert user.first_name == "John"
      assert user.last_name == "Doe"
      assert user.cpf == "000.000.000-00"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
