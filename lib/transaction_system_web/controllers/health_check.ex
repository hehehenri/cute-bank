defmodule TransactionSystemWeb.HealthCheck do
  use TransactionSystemWeb, :controller

  def run(conn, _opts) do
    conn
    |> json(%{message: "alive"})
  end
end
