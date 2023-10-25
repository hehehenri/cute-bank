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

  scope "/api", TransactionSystemWeb do
    pipe_through :api
    post "/user/create", UserController, :create
    post "/user/login", UserController, :login
  end
end
