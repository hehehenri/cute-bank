defmodule TransactionSystem.Transactions do
  import Ecto.Query, warn: false
  alias Ecto.UUID
  alias TransactionSystem.Repo

  alias TransactionSystem.Transactions.Entry
  alias TransactionSystem.Accounts

  def create_entry(sender, receiver_cpf, amount) when is_number(amount) do
    {:ok, {credit, debit}} = Repo.transaction(fn ->
      receiver = Accounts.get_user_by_cpf!(receiver_cpf)

      transaction_id = UUID.generate()

      credit_entry = sender
      |> Ecto.build_assoc(:entries)
      |> Entry.changeset(%{
        amount: amount,
        kind: :credit,
        transaction_id: transaction_id,
      })
      |> Repo.insert!()

      debit_entry = receiver
      |> Ecto.build_assoc(:entries)
      |> Entry.changeset(%{
        amount: amount,
        kind: :debit,
        transaction_id: transaction_id,
      })
      |> Repo.insert!()

      {credit_entry, debit_entry}
    end)

    {:ok, credit, debit}
  end
end
