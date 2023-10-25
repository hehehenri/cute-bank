defmodule TransactionSystemWeb.UserController do
  use TransactionSystemWeb, :controller

  alias TransactionSystemWeb.Auth.Guardian
  alias TransactionSystem.Accounts
  alias TransactionSystem.Accounts.User

  action_fallback TransactionSystemWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
          {:ok, token} <- Guardian.generate_token(user)
    do
      conn
      |> put_status(:created)
      |> render(:show, user: user, token: token)
    end
  end
end
