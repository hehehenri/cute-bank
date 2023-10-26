defmodule TransactionSystemWeb.EntryControllerTest do
  use TransactionSystemWeb.ConnCase

  alias TransactionSystemWeb.Auth.Guardian
  alias TransactionSystem.Transactions.Entry
  import TransactionSystem.AccountsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create transaction" do
    test "create and render user when data is valid", %{conn: conn} do
      sender = user_fixture()
      receiver = user_fixture(%{cpf: "222.222.222-22"})

      payload = %{
        receiver_cpf: receiver.cpf,
        amount: 500,
      }

      {:ok, token, _sender} = Guardian.generate_token(sender)

      conn = conn
      |> put_req_header("authorization", "Bearer " <> token)
      |> post(~p"/api/transaction/create", transaction: payload)

      assert %{
        "debit" => %{
          "amount" => 500,
        },
        "credit" => %{
          "amount" => 500,
        },
      } = json_response(conn, 201)["data"]
    end
  end
end
