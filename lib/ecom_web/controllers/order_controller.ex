defmodule EcomWeb.OrderController do
  use EcomWeb, :controller

  alias Ecom.Orders
  alias Ecom.Mpesa

  def create(conn, _) do

    
    case Orders.complete_order(conn.assigns.cart) do
      {:ok, order} ->

        Task.start(fn -> 
        
         with {:ok, access_token} <- Mpesa.authorize(),{:ok, stk_response}<- Mpesa.request(access_token, to_string(order.total_price |> Decimal.round), conn.assigns.current_admin.phone_number)|> IO.inspect() do
          :ok
         else
          _ ->
            :error
         end


        end)

        conn
        |> put_flash(:info, "Order created successfully.")
        |> redirect(to: ~p"/orders/#{order}")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "There was an error processing your order")
        |> redirect(to: ~p"/cart")
    end
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(conn.assigns.current_uuid, id)
    render(conn, :show, order: order)
  end
end