defmodule TransactionSystemWeb.TransactionController do
  use TransactionSystemWeb, :controller

  alias TransactionSystem.Transactions
  alias TransactionSystem.Transactions.Entry
  import Guardian.Plug

  action_fallback TransactionSystemWeb.FallbackController

  defp parse_payload(payload) do
    case payload do
      %{"transaction" => %{"amount" => amount, "receiver_cpf" => receiver_cpf}} -> {:ok, amount, receiver_cpf}
      _payload -> {:error, :invalid_payload}
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
      {:error, :not_enough_funds} -> conn
        |> put_status(400)
        |> json(%{message: "not enough funds"})
      {:error, :invalid_payload} -> conn
        |> put_status(422)
        |> json(%{message: "invalid payload"})
    end
  end
end
