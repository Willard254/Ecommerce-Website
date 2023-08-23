defmodule Ecom.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecom.Catalog` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title",
        picture: "some picture",
        price: "120.5",
        views: 42
      })
      |> Ecom.Catalog.create_product()

    product
  end
end
