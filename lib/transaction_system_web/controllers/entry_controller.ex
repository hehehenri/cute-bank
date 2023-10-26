defmodule TransactionSystemWeb.EntryController do
  use TransactionSystemWeb, :controller

  alias TransactionSystem.Transactions
  alias TransactionSystem.Transactions.Entry
  import Guardian.Plug

  action_fallback TransactionSystemWeb.FallbackController

  def create(conn, %{"transaction" => %{"receiver_cpf" => receiver_cpf, "amount" => amount}}) do
    auth_user = current_resource(conn)

    with {:ok, %Entry{} = credit, %Entry{} = debit} <- Transactions.create_entry(auth_user, receiver_cpf, amount) do
      conn
      |> put_status(:created)
      |> render(:show, credit: credit, debit: debit)
    end
  end

end
