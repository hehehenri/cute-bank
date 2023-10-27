defmodule TransactionSystem.Transactions.Entry do
  alias TransactionSystem.Transactions
  alias TransactionSystem.Transactions.Entry
  alias TransactionSystem.Repo
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "transaction_entries" do
    field      :amount,         :integer
    field      :kind,           Ecto.Enum, values: [:credit, :debit]
    field      :transaction_id, :binary_id
    field      :refunded_at,    :utc_datetime
    belongs_to :user,           TransactionSystem.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:amount, :kind, :transaction_id, :refunded_at])
    |> validate_required([:amount, :kind, :transaction_id])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
  end

  def get_with_transaction_id(transaction_id) do
    query = from e in Entry,
      where: e.transaction_id == ^transaction_id and is_nil(e.refunded_at),
      order_by: [desc: e.kind]

    transactions = query
    |> lock("FOR UPDATE NOWAIT")
    |> Repo.all()

    case transactions do
      [] -> {:error, :transaction_not_found}
      [credit, debit | _] -> {:ok, credit, debit}
    end
  end

  def refund(%Entry{} = entry) do
    entry
    |> Entry.changeset(%{refunded_at: UTCDateTime.utc_now})
    |> Repo.update()

    entry = entry
    |> Repo.preload(:user)

    case entry.kind do
      :credit -> Transactions.deposit(entry.user, entry.amount)
      :debit -> Transactions.withdraw!(entry.user, entry.amount)
    end
  end
end
