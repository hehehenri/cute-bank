defmodule TransactionSystem.TransactionsTest do
  alias TransactionSystem.Transactions.Balance
  use TransactionSystem.DataCase

  alias TransactionSystem.Transactions

  describe "transaction_entries" do
    import TransactionSystem.AccountsFixtures

    test "create_entry with valid data creates a entry and updates user balance" do
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

      %Balance{total: sender_balance} = sender |> Ecto.assoc(:balance) |> Repo.one!()
      %Balance{total: receiver_balance} = receiver |> Ecto.assoc(:balance) |> Repo.one!()

      assert sender_balance == 0
      assert receiver_balance == 500
    end

    test "create_entry consistently updates the user balance and race conditions doesn't occur" do
      sender = user_fixture()
      receiver = user_fixture(%{cpf: "222.222.222-22"})

      sender
      |> Ecto.assoc(:balance)
      |> Repo.update_all(set: [total: 10])


      # Don't spawn more than 10 tasks, since there are only 10 database connections available
      tasks = Enum.map(1..10, fn _ ->
        Task.async(fn ->
          {:ok, {_credit, _debit}} = Transactions.create_entry(sender, receiver.cpf, 1)
        end)
      end)

      Task.await_many(tasks, :infinity)

      %Balance{total: sender_balance} = sender |> Ecto.assoc(:balance) |> Repo.one!()
      assert sender_balance == 0

      %Balance{total: receiver_balance} = receiver |> Ecto.assoc(:balance) |> Repo.one!()
      assert receiver_balance == 10
    end

    test "create_entry fails to create entries when sender doesn't have enough money" do
      sender = user_fixture()
      receiver = user_fixture(%{cpf: "222.222.222-22"})

      assert {:error, :not_enough_funds} = Transactions.create_entry(sender, receiver.cpf, 1)
    end
  end

  describe "user_balance_deposit_and_withdraw" do
    test "withdraw updates user balance" do
      sender = user_fixture()
      receiver = user_fixture(%{cpf: "222.222.222-22"})

      sender
      |> Ecto.assoc(:balance)
      |> Repo.update_all(set: [total: 10])

      pog = Transactions.withdraw(sender, 5)
    end
  end
end
