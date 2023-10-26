defmodule TransactionSystem.AccountsTest do
  use TransactionSystem.DataCase

  alias TransactionSystem.Accounts

  describe "users" do
    alias TransactionSystem.Accounts.User

    import TransactionSystem.AccountsFixtures

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      payload = %{
        first_name: "John",
        last_name: "Doe",
        cpf: "000.000.000-00",
        password: "password",
      }

      assert {:ok, %User{} = user} = Accounts.create_user(payload)
      assert user.first_name == "John"
      assert user.last_name == "Doe"
      assert user.cpf == "000.000.000-00"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(%{
          first_name: nil,
          last_name: nil,
          cpf: nil,
          password: nil,
        }
      )
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "create_user/1 also creates the user balance assoc" do
      payload = %{
        first_name: "John",
        last_name: "Doe",
        cpf: "000.000.000-00",
        password: "password",
      }

      assert {:ok, %User{} = user} = Accounts.create_user(payload)

      balance = Ecto.assoc(user, :balance) |> Repo.one!()

      assert balance.total == 0
    end
  end
end
