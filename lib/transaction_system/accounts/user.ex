defmodule TransactionSystem.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :last_name,  :string
    field :cpf,        :string
    field :balance,    :integer, default: 0
    field :password,   :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :balance, :cpf, :password])
    |> validate_required([:first_name, :last_name, :cpf, :password])
    |> validate_format(:cpf, ~r/^\d{3}\.\d{3}\.\d{3}-\d{2}$/)
    |> unique_constraint(:cpf, message: "already registered")
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
