defmodule TransactionSystem.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :last_name,  :string
    field :cpf,        :string
    field :balance,    :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :balance, :cpf])
    |> validate_required([:first_name, :last_name, :balance, :cpf])
    |> validate_format(:cpf, ~r/^\d{3}\.\d{3}\.\d{3}-\d{2}$/)
    |> unique_constraint(:cpf)
  end
end
