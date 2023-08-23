defmodule Ecom.Repo do
  use Ecto.Repo,
    otp_app: :ecom,
    adapter: Ecto.Adapters.Postgres
end
