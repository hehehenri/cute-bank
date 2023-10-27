defmodule TransactionSystem.Repo.Migrations.CreateUserBalances do
  use Ecto.Migration

  def change do
    create table(:user_balances) do
      add :total, :bigint
      add :user_id, references(:users)

      timestamps(type: :utc_datetime)
    end
  end
end
