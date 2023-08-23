defmodule EcomWeb.CartHTML do
    use EcomWeb, :html
  
    alias Ecom.ShoppingCart
    
    embed_templates "cart_html/*"
  
    def currency_to_str(%Decimal{} = val), do: "Kshs.#{Decimal.round(val, 2)}"
  end