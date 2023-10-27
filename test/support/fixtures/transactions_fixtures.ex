defmodule TransactionSystem.TransactionsFixtures do
  alias TransactionSystem.Transactions.Balance
  alias TransactionSystem.Repo
  alias TransactionSystem.Accounts.User

  def refresh(%User{} = user) do
    Repo.get!(User, user.id)
    |> Repo.preload([:balance, :entries])
  end

  def deposit(%User{} = user, amount) when is_integer(amount) do
    balance = user |> Ecto.assoc(:balance) |> Repo.one!()

    balance
    |> Balance.changeset(%{total: balance.total + amount})
    |> Repo.update!()
  end

  def withdraw(%User{} = user, amount) when is_integer(amount) do
    balance = user |> Ecto.assoc(:balance) |> Repo.one!()

    balance
    |> Balance.changeset(%{total: balance.total - amount})
    |> Repo.update!()
  end
end
