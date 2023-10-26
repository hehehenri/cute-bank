defmodule TransactionSystemWeb.EntryControllerTest do
  use TransactionSystemWeb.ConnCase

  alias TransactionSystem.Transactions.Balance
  alias TransactionSystem.Accounts.User
  alias TransactionSystem.Repo
  alias TransactionSystemWeb.Auth.Guardian
  import TransactionSystem.AccountsFixtures

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
        receiver_cpf: receiver.cpf,
      }

      {:ok, token, _sender} = Guardian.generate_token(sender)

      conn = conn
      |> put_req_header("authorization", "Bearer " <> token)
      |> post(~p"/api/transaction/create", %{transaction: payload})

      assert %{
        "debit" => %{"amount" => 500} = debit,
        "credit" => %{"amount" => 500} = credit,
      } = json_response(conn, 201)["data"]

      assert credit["user_id"] == sender.id
      assert debit["user_id"] == receiver.id
      assert credit["transaction_id"] == debit["transaction_id"]

      %Balance {total: sender_balance} = sender |> get_balance()
      assert sender_balance == 0

      %Balance {total: receiver_balance} = receiver |> get_balance()
      assert receiver_balance == 500
    end
  end

  defp get_balance(%User{} = user) do
    user |> Ecto.assoc(:balance) |> Repo.one!()
  end
end
