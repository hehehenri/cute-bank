defmodule TransactionSystem.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias TransactionSystem.Transactions.Balance
  alias TransactionSystem.Accounts.User
  alias TransactionSystem.Repo

  schema "users" do
    field :first_name, :string
    field :last_name,  :string
    field :cpf,        :string
    field :password,   :string
    has_many :entries, TransactionSystem.Transactions.Entry
    has_one :balance, TransactionSystem.Transactions.Balance

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :cpf, :password])
    |> validate_required([:first_name, :last_name, :cpf, :password])
    |> validate_format(:cpf, ~r/^\d{3}\.\d{3}\.\d{3}-\d{2}$/)
    |> unique_constraint(:cpf, message: "already registered")
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

  def assoc_and_lock(%User{} = user, assoc) do
    user
    |> Ecto.assoc(assoc)
    |> lock("FOR UPDATE NOWAIT")
  end

  def total_balance(%User{} = user) do
    user = user |> Repo.preload(:balance)
    user.balance.total
  end

  def create(attrs \\ %{}) do
    with {:ok, user} <- %User{}
      |> User.changeset(attrs)
      |> Repo.insert()
    do
      user
      |> Ecto.build_assoc(:balance)
      |> Balance.changeset(%{})
      |> Repo.insert()

      {:ok, user}
    end
  end
end
