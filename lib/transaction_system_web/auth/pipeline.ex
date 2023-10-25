defmodule TransactionSystemWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline, otp_app: :transaction_system,
    module: TransactionSystemWeb.Auth.Guardian,
    error_handler: TransactionSystemWeb.Auth.GuardianErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
