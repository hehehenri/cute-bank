defmodule TransactionSystem.Repo.Migrations.CreateTransactionEntries do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE entry_kind AS ENUM ('debit', 'credit')"
    drop_query = "DROP TYPE entry_kind"
    execute(create_query, drop_query)

    create table(:transaction_entries) do
      add :amount, :bigint
      add :kind,   :entry_kind
      add :transaction_id, :binary_id
      add :user_id, references(:users)
      add :refunded_at, :utc_datetime, null: true

      timestamps(type: :utc_datetime)
    end
  end
end
