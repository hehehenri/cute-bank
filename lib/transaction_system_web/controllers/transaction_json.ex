defmodule TransactionSystemWeb.TransactionJSON do
  alias TransactionSystem.Transactions.Entry

  def index(%{entries: entries}) do
    %{data: for(entry <- entries, do: data(entry))}
  end

  def show(%{debit: debit, credit: credit}) do
    %{data: %{
      debit: data(debit),
      credit: data(credit),
    }}
  end

  defp data(%Entry{} = entry) do
    %{
      id: entry.id,
      amount: entry.amount,
      transaction_id: entry.transaction_id,
      user_id: entry.user_id,
    }
  end
end
