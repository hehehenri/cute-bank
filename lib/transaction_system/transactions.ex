defmodule TransactionSystem.Transactions do
  import Ecto.Query, warn: false
  alias Ecto.Adapter.Transaction
  alias TransactionSystem.Transactions.Balance
  alias TransactionSystem.Transactions.Exceptions.NotEnoughFunds
  alias TransactionSystem.Accounts.User
  alias Ecto.UUID
  alias TransactionSystem.Repo

  alias TransactionSystem.Transactions.Entry
  alias TransactionSystem.Accounts

  def search_date_range(start_date, end_date, %User{} = user) do
    start_date = start_date |> UTCDateTime.from_iso8601!()
    end_date = end_date |> UTCDateTime.from_iso8601!()

    Entry.date_range(start_date, end_date, user.id)
    |> Repo.all()
  end

  def create_entry(sender, receiver_cpf, amount) when is_integer(amount) do
    try do
      create_entry_transaction(sender, receiver_cpf, amount)
    rescue
      # TODO: this smells, fix it later
      NotEnoughFunds -> {:error, :not_enough_funds}
    end
  end

  def deposit(%User{} = user, amount) when is_integer(amount) do
    %Balance{total: total} = deposit!(user, amount)

    {:ok, total}
  end

  def withdraw(%User{} = user, amount) when is_integer(amount) do
    try do
      %Balance{total: total} = withdraw!(user, amount)

      {:ok, total}
    rescue
      NotEnoughFunds -> {:error, :not_enough_funds}
    end
  end

  def refund(%User{} = user, transaction_id) do
    {:ok, result} =
      Repo.transaction(fn ->
        with {:ok, credit, debit} <- Entry.get_with_transaction_id(transaction_id) do
          if credit.user_id == user.id do
            try do
              credit |> Entry.refund()
              debit |> Entry.refund()

              :ok
            rescue
              NotEnoughFunds -> {:error, :not_enough_funds}
            end
          else
            {:error, :user_is_not_the_transaction_owner}
          end
        end
      end)

    result
  end

  def balance(%User{} = user) do
    user |> User.total_balance()
  end

  def sum_transactions([], acc) do
    acc
  end

  def sum_transactions([%Entry{kind: :credit, amount: amount} | transactions], acc) do
    sum_transactions(transactions, acc - amount)
  end

  def sum_transactions([%Entry{kind: :debit, amount: amount} | transactions], acc) do
    sum_transactions(transactions, acc + amount)
  end

  def check_transactions(%User{} = user) do
    transactions = user |> User.entries() |> Repo.all()
    user_balance = user |> User.total_balance()
    calc_balance = sum_transactions(transactions, 0)

    {user_balance, calc_balance}
  end

  def deposit!(%Balance{total: total} = balance, amount) do
    balance
    |> Balance.changeset(%{total: total + amount})
    |> Repo.update!()
  end

  def deposit!(%User{} = user, amount) do
    balance = user |> User.assoc_and_lock(:balance) |> Repo.one!()
    deposit!(balance, amount)
  end

  def withdraw!(%Balance{total: total} = balance, amount) do
    if total < amount do
      raise NotEnoughFunds
    end

    balance
    |> Balance.changeset(%{total: total - amount})
    |> Repo.update!()
  end

  def withdraw!(%User{} = user, amount) do
    balance = user |> User.assoc_and_lock(:balance) |> Repo.one!()
    withdraw!(balance, amount)
  end

  defp create_entry_transaction(sender, receiver_cpf, amount) when is_number(amount) do
    Repo.transaction(fn ->
      with receiver <- Accounts.get_user_by_cpf!(receiver_cpf) do
        withdraw!(sender, amount)
        deposit!(receiver, amount)

        transaction_id = UUID.generate()

        credit =
          sender
          |> Ecto.build_assoc(:entries)
          |> Entry.changeset(%{
            amount: amount,
            kind: :credit,
            transaction_id: transaction_id
          })
          |> Repo.insert!()

        debit =
          receiver
          |> Ecto.build_assoc(:entries)
          |> Entry.changeset(%{
            amount: amount,
            kind: :debit,
            transaction_id: transaction_id
          })
          |> Repo.insert!()

        {credit, debit}
      end
    end)
  end
end
