defmodule TransactionSystem.Transactions do
  import Ecto.Query, warn: false
  alias TransactionSystem.Transactions.Balance
  alias TransactionSystem.Transactions.Exceptions.NotEnoughFunds
  alias TransactionSystem.Accounts.User
  alias Ecto.UUID
  alias TransactionSystem.Repo

  alias TransactionSystem.Transactions.Entry
  alias TransactionSystem.Accounts

  defp get_user_balance_and_lock(%User{} = user) do
    balance = user
    |> Ecto.assoc(:balance)
    |> lock("FOR SHARE NOWAIT")
    |> Repo.one()

    case balance do
      nil -> {:error, :user_not_found}
      %Balance{} = balance -> {:ok, balance}
    end
  end

  defp create_entry_transaction(sender, receiver_cpf, amount) when is_number(amount) do
    Repo.transaction(fn ->
      with receiver <- Accounts.get_user_by_cpf!(receiver_cpf),
           {:ok, receiver_balance} <- receiver |> get_user_balance_and_lock(),
           {:ok, sender_balance} <- sender |> get_user_balance_and_lock()
      do
        if sender_balance.total < amount do
          raise NotEnoughFunds
        end

        sender_balance
        |> Balance.changeset(%{
          total: sender_balance.total - amount
        })
        |> Repo.update!()

        receiver_balance
        |> Balance.changeset(%{
          total: receiver_balance.total + amount
        })

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

        IO.inspect(debit)

        {credit, debit}
      end
    end)
  end


  def create_entry(sender, receiver_cpf, amount) when is_number(amount) do
    try do
      create_entry_transaction(sender, receiver_cpf, amount)
    rescue
      # TODO: this smells, fix it later
      NotEnoughFunds -> {:error, :not_enough_funds}
    end
  end
end
