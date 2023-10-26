defmodule TransactionSystemWeb.TransactionController do
  use TransactionSystemWeb, :controller

  alias TransactionSystem.Transactions
  alias TransactionSystem.Transactions.Entry
  import Guardian.Plug

  action_fallback TransactionSystemWeb.FallbackController

  defp not_enough_funds_resp(conn) do
    conn
      |> put_status(400)
      |> json(%{message: "not enough funds"})
  end

  defp invalid_payload_resp(conn) do
   conn
        |> put_status(422)
        |> json(%{message: "invalid payload"})
  end

  defp parse_payload(%{"transaction" => %{"amount" => amount, "receiver_cpf" => receiver_cpf}}) do
    {:ok, amount, receiver_cpf}
  end

  defp parse_payload(%{"amount" => amount}) do
    {:ok, amount}
  end

  defp parse_payload(_payload) do
    {:error, :invalid_payload}
  end

  def deposit(conn, payload) do
    user = current_resource(conn)

    with {:ok, amount} <- parse_payload(payload),
         {:ok, amount} <- Transactions.deposit(user, amount) do
      conn |> put_status(200) |> json(%{total: amount})
    else
      {:error, :invalid_payload} -> invalid_payload_resp(conn)
    end
  end

  def withdraw(conn, payload) do
    user = current_resource(conn)

    with {:ok, amount} <- parse_payload(payload),
         {:ok, amount} <- Transactions.withdraw(user, amount) do
      conn |> put_status(200) |> json(%{total: amount})
    else
      {:error, :not_enough_funds} -> not_enough_funds_resp(conn)
      {:error, :invalid_payload} -> invalid_payload_resp(conn)
    end
  end

  def create(conn, payload) do
    sender = current_resource(conn)

    with {:ok, amount, receiver_cpf} <- parse_payload(payload),
         {:ok, {%Entry{} = credit, %Entry{} = debit}} <- Transactions.create_entry(sender, receiver_cpf, amount) do

      conn
      |> put_status(:created)
      |> render(:show, credit: credit, debit: debit)
    else
      {:error, :not_enough_funds} -> not_enough_funds_resp(conn)
      {:error, :invalid_payload} -> invalid_payload_resp(conn)
    end
  end
end
