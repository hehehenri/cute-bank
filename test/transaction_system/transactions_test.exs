defmodule TransactionSystem.TransactionsTest do
  alias TransactionSystem.Transactions.Balance
  use TransactionSystem.DataCase

  alias TransactionSystem.Transactions

  describe "transaction_entries" do
    import TransactionSystem.AccountsFixtures

    test "create_entry/1 with valid data creates a entry and updates user balance" do
      sender = user_fixture()
      receiver = user_fixture(%{cpf: "222.222.222-22"})

      sender
      |> Ecto.assoc(:balance)
      |> Repo.update_all(set: [total: 500])

      assert {:ok, {credit, debit}} = Transactions.create_entry(sender, receiver.cpf, 500)
      assert credit.user_id == sender.id
      assert credit.amount == 500
      assert credit.kind == :credit

      assert debit.user_id == receiver.id
      assert debit.amount == 500
      assert debit.kind == :debit

      sender_balance = sender |> Ecto.assoc(:balance) |> Repo.one!()
      receiver_balance = receiver |> Ecto.assoc(:balance) |> Repo.one!()

      assert sender_balance.total == 0
      assert receiver_balance.total == 500
    end
  end
end
