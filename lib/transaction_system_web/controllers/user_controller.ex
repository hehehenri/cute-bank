defmodule TransactionSystemWeb.UserController do
  use TransactionSystemWeb, :controller

  alias TransactionSystemWeb.Auth.ErrorResponse.Unauthorized
  alias TransactionSystemWeb.Auth.Guardian
  alias TransactionSystem.Accounts
  alias TransactionSystem.Accounts.User

  action_fallback TransactionSystemWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
          {:ok, token, _user} <- Guardian.generate_token(user)
    do
      conn
      |> put_status(:created)
      |> render(:show, user: user, token: token)
    end
  end

  def login(conn, %{"cpf" => cpf, "password" => password}) do
    with {:ok, token, user} <- Guardian.auth(cpf, password) do
      conn
      |> put_status(:ok)
      |> render(:show, user: user, token: token)
    else
      {:error, :invalid_credentials} -> raise Unauthorized, message: "Invalid credentials"
    end
  end
end
