defmodule TransactionSystem.Repo do
  use Ecto.Repo,
    otp_app: :transaction_system,
    adapter: Ecto.Adapters.Postgres
end
