defmodule TransactionSystemWeb.Router do
  use TransactionSystemWeb, :router

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

    get  "/transaction",        TransactionController, :list
    post "/transaction/create", TransactionController, :create
    post "/transaction/refund", TransactionController, :refund

    get  "/balance",            TransactionController, :balance
    post "/balance/withdraw",   TransactionController, :withdraw
    post "/balance/deposit",    TransactionController, :deposit
  end
end
