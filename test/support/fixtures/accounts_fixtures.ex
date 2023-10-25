defmodule TransactionSystem.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TransactionSystem.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        balance: 0,
        first_name: "John",
        last_name: "Doe",
        cpf: "111.111.111-00",
        password: "password"
      })
      |> TransactionSystem.Accounts.create_user()

    user
  end
end
