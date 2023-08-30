defmodule Ecom.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :description, :string
    field :title, :string
    field :picture, Ecom.FileImage.Type
    field :price, :decimal
    field :views, :integer

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:picture, :title, :description, :price, :views])
    |> validate_required([:picture, :title, :description, :price, :views])
  end
end