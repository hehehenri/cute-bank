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
    post "/transaction/create", TransactionController, :create
  end
end
