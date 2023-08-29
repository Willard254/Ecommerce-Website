defmodule EcomWeb.Router do
  use EcomWeb, :router

  import EcomWeb.AdminAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EcomWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin
    plug :fetch_current_user
    plug :fetch_current_cart
  end

  defp fetch_current_user(conn, _) do
    if user_uuid = get_session(conn, :current_uuid) do
      assign(conn, :current_uuid, user_uuid)
    else
      new_uuid = Ecto.UUID.generate()
    
      conn
      |> assign(:current_uuid, new_uuid)
      |> put_session(:current_uuid, new_uuid)
    end
  end
    
  alias Ecom.ShoppingCart
  
  defp fetch_current_cart(conn, _opts) do
    if cart = ShoppingCart.get_cart_by_user_uuid(conn.assigns.current_uuid) do
      assign(conn, :cart, cart)
    else
      {:ok, new_cart} = ShoppingCart.create_cart(conn.assigns.current_uuid)
      assign(conn, :cart, new_cart)
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EcomWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/", EcomWeb do
    pipe_through [:browser, :require_authenticated_admin]

    resources "/products", ProductController
    resources "/cart_items", CartItemController, only: [:create, :delete]
    get "/cart", CartController, :show
    put "/cart", CartController, :update
    resources "/orders", OrderController, only: [:create, :show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", EcomWeb do
  #   pipe_through [:api, :require_authenticated_admin]

  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ecom, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EcomWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", EcomWeb do
    pipe_through [:browser, :redirect_if_admin_is_authenticated]

    live_session :redirect_if_admin_is_authenticated,
      on_mount: [{EcomWeb.AdminAuth, :redirect_if_admin_is_authenticated}] do
      live "/admins/register", AdminRegistrationLive, :new
      live "/admins/log_in", AdminLoginLive, :new
      live "/admins/reset_password", AdminForgotPasswordLive, :new
      live "/admins/reset_password/:token", AdminResetPasswordLive, :edit
    end

    post "/admins/log_in", AdminSessionController, :create
  end

  scope "/", EcomWeb do
    pipe_through [:browser, :require_authenticated_admin]

    live_session :require_authenticated_admin,
      on_mount: [{EcomWeb.AdminAuth, :ensure_authenticated}] do
      live "/admins/settings", AdminSettingsLive, :edit
      live "/admins/settings/confirm_email/:token", AdminSettingsLive, :confirm_email
    end
  end

  scope "/", EcomWeb do
    pipe_through [:browser]

    delete "/admins/log_out", AdminSessionController, :delete

    live_session :current_admin,
      on_mount: [{EcomWeb.AdminAuth, :mount_current_admin}] do
      live "/admins/confirm/:token", AdminConfirmationLive, :edit
      live "/admins/confirm", AdminConfirmationInstructionsLive, :new
    end
  end
end