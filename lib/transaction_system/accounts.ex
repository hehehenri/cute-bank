defmodule TransactionSystem.Accounts do
  import Ecto.Query, warn: false
  alias TransactionSystem.Transactions.Balance
  alias Hex.API.User
  alias TransactionSystem.Repo

  alias TransactionSystem.Accounts.User

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_cpf!(cpf) do
    User
    |> where(cpf: ^cpf)
    |> Repo.one!()
  end

  def create_user(attrs \\ %{}) do
    User.create(attrs)
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
