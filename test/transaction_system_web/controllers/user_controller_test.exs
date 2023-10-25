defmodule TransactionSystemWeb.UserControllerTest do
  use TransactionSystemWeb.ConnCase

  import TransactionSystem.AccountsFixtures

  alias TransactionSystem.Accounts.User

  @create_attrs %{
    first_name: "some first_name",
    last_name: "some last_name",
    cpf: "000.000.000-00",
    password: "password",
  }

  @invalid_attrs %{
    balance: "invalid-balance",
    first_name: nil,
    last_name: nil,
    cpf: nil,
    password: nil,
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/user/create", user: @create_attrs)

      assert %{
               "balance" => 0,
               "first_name" => "some first_name",
               "last_name" => "some last_name",
               "cpf" => "000.000.000-00",
             } = json_response(conn, 201)["data"]["user"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/user/create", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
