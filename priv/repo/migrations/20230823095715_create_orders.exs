defmodule Ecom.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :user_uuid, :uuid
      add :total_price, :decimal, precision: 15, scale: 2, null: false

      timestamps()
    end
  end
end
