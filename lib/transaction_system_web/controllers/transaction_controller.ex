defmodule TransactionSystemWeb.TransactionController do
  use TransactionSystemWeb, :controller

  alias Plug.Conn
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

  def search(conn, %{"start_date" => start_date, "end_date" => end_date}) do
    user = current_resource(conn)
    entries = Transactions.search_date_range(start_date, end_date, user)

    conn
    |> put_status(200)
    |> render(:index, entries: entries)
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

  def refund(conn, %{"transaction_id" => transaction_id}) do
    user = current_resource(conn)

    Transactions.refund(user, transaction_id)
    |> refund_response(conn)
  end

  defp refund_response(:ok, conn) do
    conn
    |> put_status(200)
    |> json(%{message: "transaction refunded"})
  end

  defp refund_response({:error, :transaction_not_found}, conn) do
    conn
    |> put_status(404)
    |> json(%{message: "transaction not found"})
  end

  defp refund_response({:error, :not_enough_funds}, conn) do
    conn
    |> put_status(400)
    |> json(%{message: "not enough funds"})
  end

  defp refund_response({:error, :user_is_not_the_transaction_owner}, conn) do
    conn
    |> put_status(403)
    |> json(%{message: "only transactions made by you can be refunded"})
  end

  def balance(conn, _opts) do
    user = current_resource(conn)
    total = user |> Transactions.balance()

    conn
      |> json(%{balance: total})
  end
end
