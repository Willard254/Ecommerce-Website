defmodule Ecom.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :picture, :string
      add :title, :string
      add :description, :string
      add :price, :decimal, precision: 15, scale: 2, null: false
      add :views, :integer, default: 0, null: false

      timestamps()
    end
  end
end