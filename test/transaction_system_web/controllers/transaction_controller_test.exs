defmodule TransactionSystemWeb.EntryControllerTest do
  use TransactionSystemWeb.ConnCase

  alias TransactionSystem.Transactions
  alias TransactionSystem.Transactions.Entry
  alias TransactionSystem.Transactions.Balance
  alias TransactionSystem.Accounts.User
  alias TransactionSystem.Repo
  alias TransactionSystemWeb.Auth.Guardian

  import TransactionSystem.AccountsFixtures
  import TransactionSystem.TransactionsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create transaction" do
    test "create and render user when data is valid", %{conn: conn} do
      sender = user_fixture()
      receiver = user_fixture(%{cpf: "222.222.222-22"})

      sender
      |> Ecto.assoc(:balance)
      |> Repo.update_all(set: [total: 500])

      payload = %{
        amount: 500,
        receiver_cpf: receiver.cpf
      }

      {:ok, token, _sender} = Guardian.generate_token(sender)

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/transaction/create", %{transaction: payload})

      assert %{
               "debit" => %{"amount" => 500} = debit,
               "credit" => %{"amount" => 500} = credit
             } = json_response(conn, 201)["data"]

      assert credit["user_id"] == sender.id
      assert debit["user_id"] == receiver.id
      assert credit["transaction_id"] == debit["transaction_id"]

      %Balance{total: sender_balance} = sender |> get_balance()
      assert sender_balance == 0

      %Balance{total: receiver_balance} = receiver |> get_balance()
      assert receiver_balance == 500
    end
  end

  describe "refund transaction" do
    test "refund transaction and its effects", %{conn: conn} do
      sender = user_fixture()
      receiver = user_fixture(%{cpf: "222.222.222-22"})

      sender
      |> Ecto.assoc(:balance)
      |> Repo.update_all(set: [total: 10])

      {:ok, {%Entry{transaction_id: transaction_id} = _credit, _debit}} =
        Transactions.create_entry(sender, receiver.cpf, 5)

      {:ok, token, _sender} = Guardian.generate_token(sender)

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/transaction/refund", %{transaction_id: transaction_id})

      assert %{"message" => "transaction refunded"} = json_response(conn, 200)

      sender = sender |> refresh()
      assert sender.balance.total == 10

      receiver = receiver |> refresh()
      assert receiver.balance.total == 0
    end
  end

  describe "search transaction entries" do
    test "search return transaction entries", %{conn: conn} do
      sender = user_fixture()
      receiver = user_fixture(%{cpf: "222.222.222-22"})
      sender |> deposit(3)

      start_date = DateTime.now!("Etc/UTC") |> DateTime.to_iso8601()
      {:ok, {_credit, _debit}} = Transactions.create_entry(sender, receiver.cpf, 1)
      {:ok, {_credit, _debit}} = Transactions.create_entry(sender, receiver.cpf, 1)
      {:ok, {_credit, _debit}} = Transactions.create_entry(sender, receiver.cpf, 1)
      end_date = DateTime.now!("Etc/UTC") |> DateTime.to_iso8601()

      {:ok, token, _sender} = Guardian.generate_token(sender)

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(~p"/api/transaction/search", %{start_date: start_date, end_date: end_date})

      transactions = json_response(conn, 200)["data"]

      assert length(transactions) == 3
    end
  end

  defp get_balance(%User{} = user) do
    user |> Ecto.assoc(:balance) |> Repo.one!()
  end
end
