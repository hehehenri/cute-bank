defmodule TransactionSystemWeb.Auth.Guardian do
  use Guardian, otp_app: :transaction_system
  alias TransactionSystem.Accounts

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_resource, _claims) do
    {:error, :no_id_provided}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = Accounts.get_user!(id)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_founded}
  end

  def resource_from_claims(_claims) do
    {:error, :no_sub_provided}
  end

  def auth(cpf, password) do
    user = Accounts.get_user_by_cpf!(cpf)

    case Bcrypt.verify_pass(password, user.password) do
      true -> generate_token(user)
      false -> {:error, :invalid_credentials}
    end
  rescue
    Ecto.NoResultsError -> {:error, :invalid_credentials}
  end

  def generate_token(user) do
    # TODO: Is it possible to fail encoding?
    with {:ok, token, _claims} <- encode_and_sign(user) do
      {:ok, token}
    else
      err -> err
    end
  end
end
