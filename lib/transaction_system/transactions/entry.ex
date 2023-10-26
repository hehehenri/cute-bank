defmodule TransactionSystem.Transactions.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transaction_entries" do
    field      :amount,         :integer
    field      :kind,           Ecto.Enum, values: [:credit, :debit]
    field      :transaction_id, :binary_id
    belongs_to :user,           TransactionSystem.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:amount, :kind, :transaction_id])
    |> validate_required([:amount, :kind, :transaction_id])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
  end
end
