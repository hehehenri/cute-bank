defmodule TransactionSystem.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :balance, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
