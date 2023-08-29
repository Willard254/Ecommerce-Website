defmodule Ecom.Mpesa do
  use Ecto.Schema

  def config() do
    Application.get_env(:ecom, __MODULE__)
  end


  defp consumer_key(config) do
    config |> Keyword.get(:consumer_key)
  end

  defp consumer_secret(config) do
    config |> Keyword.get(:consumer_secret)
  end

  defp mpesa_short_code(config) do
    config |> Keyword.get(:mpesa_short_code)
  end

  defp mpesa_passkey(config) do
    config |> Keyword.get(:mpesa_passkey)
  end

  defp mpesa_env(config) do
    config |> Keyword.get(:env)
  end


  defp mpesa_callback_url(config) do
    config |> Keyword.get(:mpesa_callback_url)
  end

    def get_url do
        if mpesa_env(config()) === "sandbox" do
            "https://sandbox.safaricom.co.ke"
        else
            "https://api.safaricom.co.ke"
        end
    end

    def authorize do
      config = config()
        url = get_url() <> "/oauth/v1/generate?grant_type=client_credentials"
    
        string = consumer_key(config) <>
            ":" <> consumer_secret(config)
        token = Base.encode64(string)
    
        headers = [
          {"Authorization", "Basic #{token}"},
          {"Content-Type", "application/json"}
        ]
    
        HTTPoison.start()
        {:ok, response} = HTTPoison.get(url, headers)
        get_token(response)
    end

    def get_token(%{status_code: 400} = _response) do
        {:error, "Wrong Credentials"}
    end
    
    def get_token(%{status_code: 200, body: body} = _response) do
        {:ok, body} = body |> Poison.decode()
        {:ok, body["access_token"]}
    end

    def make_request(amount, phone) do
        case authorize() do
          {:ok, token} ->
            request(token, amount, phone)
    
          {:error, message} ->
            {:error, message}
    
          _ ->
            {:error, 'An Error occurred, try again'}
        end
    end

    def request(token, amount, phone) do

      IO.inspect(token)
      IO.inspect(amount)
      IO.inspect(phone)
      config = config()

      url = get_url() <> "/mpesa/stkpush/v1/processrequest"
      paybill = mpesa_short_code(config)
      passkey = mpesa_passkey(config) 
      {:ok, timestamp} = Timex.now() |> Timex.format("%Y%m%d%H%M%S", :strftime)
      password = Base.encode64(paybill <> passkey <> timestamp)
  
      payload = %{
        "BusinessShortCode" => paybill,
        "Password" => password,
        "Timestamp" => timestamp,
        "TransactionType" => "CustomerPayBillOnline",
        "Amount" => amount,
        "PartyA" => phone,
        "PartyB" => paybill,
        "PhoneNumber" => phone,
        "CallBackURL" => mpesa_callback_url(config),
        "AccountReference" => "reference",
        "TransactionDesc" => "description"
      }
  
      request_body = Poison.encode!(payload)
  
      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"}
      ]
  
      {:ok, response} = HTTPoison.post(url, request_body, headers)
      get_response_body(response)
    end
    
    @doc false
    def get_response_body(%{status_code: 200, body: body} = _response) do
      {:ok, _body} = body |> Poison.decode()
    end
  
    @doc false
    def get_response_body(%{status_code: 404} = _response) do
      {:error, "Invalid Access Token"}
    end
  
    @doc false
    def get_response_body(%{status_code: 500} = _response) do
      {:error,
        "Unable to lock subscriber, a transaction is already in process for the current subscriber"}
    end
end