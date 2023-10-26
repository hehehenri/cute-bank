defmodule TransactionSystemWeb.Router do
  use TransactionSystemWeb, :router
  use Plug.ErrorHandler

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn
      |> json(%{errors: message})
      |> halt()
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{reason: %{message: message}}) do
    conn
      |> json(%{errors: message})
      |> halt()
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug TransactionSystemWeb.Auth.Pipeline
  end

  scope "/api", TransactionSystemWeb do
    pipe_through :api
    get "/health_check", HealthCheck, :run
    post "/user/create", UserController, :create
    post "/user/login", UserController, :login
  end

  scope "/api", TransactionSystemWeb do
    pipe_through [:api, :auth]
    post "/transaction/create", EntryController, :create
  end
end
