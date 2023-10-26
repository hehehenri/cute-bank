defmodule TransactionSystem.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name,  :string
      add :cpf,        :string
      add :password,   :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:cpf])
  end
end
