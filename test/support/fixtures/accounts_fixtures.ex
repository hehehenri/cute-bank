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
        balance: 42,
        first_name: "some first_name",
        last_name: "some last_name"
      })
      |> TransactionSystem.Accounts.create_user()

    user
  end
end
