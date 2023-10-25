defmodule TransactionSystemWeb.Router do
  use TransactionSystemWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TransactionSystemWeb do
    pipe_through :api
    post "/user/create", UserController, :create
  end
end
