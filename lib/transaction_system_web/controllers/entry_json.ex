defmodule TransactionSystemWeb.EntryJSON do
  alias TransactionSystem.Transactions.Entry

  def index(%{transaction_entries: transaction_entries}) do
    %{data: for(entry <- transaction_entries, do: data(entry))}
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
