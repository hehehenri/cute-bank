defmodule TransactionSystemWeb.UserControllerTest do
  use TransactionSystemWeb.ConnCase

  import TransactionSystem.AccountsFixtures

  @payload %{
    first_name: "some first_name",
    last_name: "some last_name",
    cpf: "000.000.000-00",
    password: "password",
  }

  @invalid_payload%{
    first_name: nil,
    last_name: nil,
    cpf: nil,
    password: nil,
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "create and render user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/user/create", user: @payload)

      assert %{
        "first_name" => "some first_name",
        "last_name" => "some last_name",
        "cpf" => "000.000.000-00",
      } = json_response(conn, 201)["data"]["user"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/user/create", user: @invalid_payload)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  @payload %{
    cpf: "000.000.000-00",
    password: "password",
  }

  describe "login user" do
     test "login user when credentials are valid", %{conn: conn} do
        _user = user_fixture(%{cpf: "000.000.000-00", password: "password"})

        conn = post(conn, ~p"/api/user/login", @payload)
        response = json_response(conn, 200)

        assert %{
          "cpf" => "000.000.000-00",
          "first_name" => "John",
          "last_name" => "Doe",
        } = response["data"]["user"]

        assert response["data"]["token"]
     end
  end
end
