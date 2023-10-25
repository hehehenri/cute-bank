defmodule TransactionSystem.AuthTest do
  use TransactionSystem.DataCase
  alias TransactionSystemWeb.Auth.Guardian
  import TransactionSystem.AccountsFixtures

  test "auth/2 returns valid token" do
    user = user_fixture(%{password: "password"})
    {:ok, token, auth_user} = Guardian.auth(user.cpf, "password")

    {:ok, claims} = Guardian.decode_and_verify(token)
    {:ok, decoded_user} = Guardian.resource_from_claims(claims)
    assert user.id == decoded_user.id
  end
end
