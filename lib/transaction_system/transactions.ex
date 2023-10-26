defmodule TransactionSystem.Transactions do
  import Ecto.Query, warn: false
  alias TransactionSystem.Transactions.Balance
  alias TransactionSystem.Transactions.Exceptions.NotEnoughFunds
  alias TransactionSystem.Accounts.User
  alias Ecto.UUID
  alias TransactionSystem.Repo

  alias TransactionSystem.Transactions.Entry
  alias TransactionSystem.Accounts

  def create_entry(sender, receiver_cpf, amount) when is_integer(amount) do
    try do
      create_entry_transaction(sender, receiver_cpf, amount)
    rescue
      # TODO: this smells, fix it later
      NotEnoughFunds -> {:error, :not_enough_funds}
    end
  end

  def deposit(%User{} = user, amount) when is_integer(amount) do
    %Balance{total: total} = deposit_for_user!(user, amount)

    {:ok, total}
  end

  def withdraw(%User{} = user, amount) when is_integer(amount) do
    try do
      %Balance{total: total} = withdraw_for_user!(user, amount)

      {:ok, total}
    rescue
      NotEnoughFunds -> {:error, :not_enough_funds}
    end
  end

  defp deposit!(%Balance{total: total} = balance, amount) do
    balance
      |> Balance.changeset(%{total: total + amount})
      |> Repo.update!()
  end

  defp deposit_for_user!(%User{} = user, amount) do
    {:ok, balance} = get_user_balance_and_lock(user)
    deposit!(balance, amount)
  end

  defp withdraw!(%Balance{total: total} = balance, amount) do
    if total < amount do
      raise NotEnoughFunds
    end

    balance
      |> Balance.changeset(%{total: total - amount})
      |> Repo.update!()
  end

  defp withdraw_for_user!(%User{} = user, amount) do
    {:ok, balance} = get_user_balance_and_lock(user)
    withdraw!(balance, amount)
  end

  defp get_user_balance_and_lock(%User{} = user) do
    balance = user
    |> User.assoc_and_lock(:balance)
    |> Repo.one()

    case balance do
      nil -> {:error, :user_not_found}
      %Balance{} = balance -> {:ok, balance}
    end
  end

  defp create_entry_transaction(sender, receiver_cpf, amount) when is_number(amount) do
    Repo.transaction(fn ->
      with receiver <- Accounts.get_user_by_cpf!(receiver_cpf) do
        withdraw_for_user!(sender, amount)
        deposit_for_user!(receiver, amount)

        transaction_id = UUID.generate()

        credit = sender
        |> Ecto.build_assoc(:entries)
        |> Entry.changeset(%{
          amount: amount,
          kind: :credit,
          transaction_id: transaction_id,
        })
        |> Repo.insert!()

        debit = receiver
        |> Ecto.build_assoc(:entries)
        |> Entry.changeset(%{
          amount: amount,
          kind: :debit,
          transaction_id: transaction_id,
        })
        |> Repo.insert!()

        {credit, debit}
      end
    end)
  end
end
