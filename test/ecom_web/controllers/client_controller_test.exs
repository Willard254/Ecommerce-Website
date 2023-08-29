defmodule EcomWeb.ClientControllerTest do
  use EcomWeb.ConnCase

  import Ecom.AccountsFixtures

  @create_attrs %{username: "some username", phone_number: "some phone_number", encrypted_password: "some encrypted_password"}
  @update_attrs %{username: "some updated username", phone_number: "some updated phone_number", encrypted_password: "some updated encrypted_password"}
  @invalid_attrs %{username: nil, phone_number: nil, encrypted_password: nil}

  describe "index" do
    test "lists all clients", %{conn: conn} do
      conn = get(conn, ~p"/clients")
      assert html_response(conn, 200) =~ "Listing Clients"
    end
  end

  describe "new client" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/clients/new")
      assert html_response(conn, 200) =~ "New Client"
    end
  end

  describe "create client" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/clients", client: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/clients/#{id}"

      conn = get(conn, ~p"/clients/#{id}")
      assert html_response(conn, 200) =~ "Client #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/clients", client: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Client"
    end
  end

  describe "edit client" do
    setup [:create_client]

    test "renders form for editing chosen client", %{conn: conn, client: client} do
      conn = get(conn, ~p"/clients/#{client}/edit")
      assert html_response(conn, 200) =~ "Edit Client"
    end
  end

  describe "update client" do
    setup [:create_client]

    test "redirects when data is valid", %{conn: conn, client: client} do
      conn = put(conn, ~p"/clients/#{client}", client: @update_attrs)
      assert redirected_to(conn) == ~p"/clients/#{client}"

      conn = get(conn, ~p"/clients/#{client}")
      assert html_response(conn, 200) =~ "some updated username"
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      conn = put(conn, ~p"/clients/#{client}", client: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Client"
    end
  end

  describe "delete client" do
    setup [:create_client]

    test "deletes chosen client", %{conn: conn, client: client} do
      conn = delete(conn, ~p"/clients/#{client}")
      assert redirected_to(conn) == ~p"/clients"

      assert_error_sent 404, fn ->
        get(conn, ~p"/clients/#{client}")
      end
    end
  end

  defp create_client(_) do
    client = client_fixture()
    %{client: client}
  end
end
