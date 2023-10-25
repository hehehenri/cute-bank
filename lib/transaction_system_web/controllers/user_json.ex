defmodule TransactionSystemWeb.UserJSON do
  alias TransactionSystem.Accounts.User

  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  def show(%{user: user, token: token}) do
    %{data: data(user, token)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      cpf: user.cpf,
      balance: user.balance
    }
  end

  defp data(%User{} = user, token) do
    %{
      user: data(user),
      token: token
    }
  end
end
