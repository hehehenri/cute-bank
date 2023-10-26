defmodule TransactionSystem.Transactions.Balance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_balances" do
    field      :total,         :integer, default: 0
    belongs_to :user,           TransactionSystem.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(balance, attrs) do
    balance
    |> cast(attrs, [:total])
    |> validate_required([:total])
    |> validate_number(:total, greater_than_or_equal_to: 0)
  end
end
