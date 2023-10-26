defmodule TransactionSystem.TransactionsTest do
  use TransactionSystem.DataCase

  alias TransactionSystem.Transactions

  describe "transaction_entries" do
    alias TransactionSystem.Transactions.Entry

    import TransactionSystem.AccountsFixtures

    test "create_entry/1 with valid data creates a entry" do
      sender = user_fixture()
      receiver = user_fixture(%{cpf: "222.222.222-22"})

      assert {:ok, credit, debit} = Transactions.create_entry(sender, receiver.cpf, 500)
      assert credit.user_id == sender.id
      assert credit.amount == 500
      assert credit.kind == :credit

      assert debit.user_id == receiver.id
      assert debit.amount == 500
      assert debit.kind == :debit
    end
  end
end
