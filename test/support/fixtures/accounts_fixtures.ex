defmodule Ecom.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecom.Accounts` context.
  """

  def unique_admin_email, do: "admin#{System.unique_integer()}@example.com"
  def valid_admin_password, do: "hello world!"

  def valid_admin_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_admin_email(),
      password: valid_admin_password()
    })
  end

  def admin_fixture(attrs \\ %{}) do
    {:ok, admin} =
      attrs
      |> valid_admin_attributes()
      |> Ecom.Accounts.register_admin()

    admin
  end

  def extract_admin_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @doc """
  Generate a unique client username.
  """
  def unique_client_username, do: "some username#{System.unique_integer([:positive])}"

  @doc """
  Generate a client.
  """
  def client_fixture(attrs \\ %{}) do
    {:ok, client} =
      attrs
      |> Enum.into(%{
        username: unique_client_username(),
        phone_number: "some phone_number",
        encrypted_password: "some encrypted_password"
      })
      |> Ecom.Accounts.create_client()

    client
  end
end
