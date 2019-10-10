defmodule ExAliyun.Client.RPC do
  @moduledoc """
  Aliyun RPC client.

  ### Usage

  Please go to Aliyun api explorer to find how to access each service:
  https://api.aliyun.com/new#/?product=Dysmsapi&api=QuerySendDetails&params={}&tab=DEMO&lang=RUBY

  Below is an example for `SendSms`:

  ```elixir
  alias ExAliyun.Client.RPC

  client = %RPC{
    endpoint: "https://dysmsapi.aliyuncs.com",
    access_key_id: "<access_key_id>",
    access_key_secret: "<access_key_secret>",
    api_version: "2017-05-25",
  }

  params = %{
    "RegionId" => "cn-hangzhou",
    "PhoneNumbers" => "1865086****",
    "SignName" => "SignName",
    "TemplateCode" => "SMS_11111",
    "TemplateParam" => "{\"code\":123123}"
  }
  RPC.request(client, "SendSms", params)
  ```
  """
  @enforce_keys [:endpoint, :api_version, :access_key_id, :access_key_secret]
  defstruct [:endpoint, :api_version, :access_key_id, :access_key_secret]

  @type t :: %__MODULE__{
          endpoint: binary(),
          api_version: binary(),
          access_key_id: binary(),
          access_key_secret: binary(),
        }

  @spec request(__MODULE__.t(), binary(), map(), binary()) :: {:ok, map()} | {:error, map()}
  def request(client, action, params, method \\ "GET") do
    qs =
      default_params(client)
      |> Map.put(:Action, action)
      |> Map.merge(params)
      |> normalize

    signature = sign(client, qs, method)
    qs = "Signature=#{signature}&#{qs}"
    endpoint = String.trim_trailing(client.endpoint, "/") <> "/"

    request = case method do
        "GET" ->
          %HTTPoison.Request{
            method: :get,
            url: "#{endpoint}?#{qs}"
          }
        "POST" ->
          %HTTPoison.Request{
            method: :post,
            url: endpoint,
            body: qs,
            headers: [{"Content-Type", "application/x-www-form-urlencoded"}]
          }
      end

    with {:ok, resp} <- HTTPoison.request(request),
         {:ok, body} <- verify_status(resp),
         {:ok, json_data} <- Jason.decode(body),
         {:ok, resp_data} <- check_response_data(json_data) do
      {:ok, resp_data}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp verify_status(%{status_code: 200, body: body}) do
    {:ok, body}
  end
  defp verify_status(%{status_code: 400, body: body}) do
    {:ok, body}
  end
  defp verify_status(%{status_code: status_code}) do
    {:error, %{status_code: status_code}}
  end

  defp check_response_data(resp_data) do
    case resp_data["Code"] do
      "OK" -> {:ok, resp_data}
      _ -> {:error, resp_data}
    end
  end

  def normalize(params) do
    params
    |> Map.keys
    |> Enum.sort
    |> Enum.reduce(%{}, fn k, acc -> Map.put(acc, k, params[k]) end)
    |> URI.encode_query
  end

  defp sign(client, qs, method) do
    str = pop_encode(qs)
    str = "#{method}&%2F&#{str}"
    key = "#{client.access_key_secret}&"
    :crypto.hmac(:sha, key, str)
    |> Base.encode64
    |> URI.encode_www_form
  end

  defp pop_encode(str) do
    str
    |> URI.encode_www_form
    |> String.replace("+", "%20")
    |> String.replace("*", "%2A")
    |> String.replace("%7E", "~")
  end

  defp default_params(client) do
    %{
      AccessKeyId: client.access_key_id,
      Version: client.api_version,
      Format: "JSON",
      SignatureMethod: "HMAC-SHA1",
      SignatureVersion: "1.0",
      SignatureNonce: random_nonce(),
      Timestamp: timestamp(),
    }
  end

  defp timestamp do
    DateTime.utc_now()
    |> Map.put(:microsecond, {0, 0})
    |> DateTime.to_iso8601
  end

  defp random_nonce(len \\ 10) do
    :crypto.strong_rand_bytes(len)
    |> Base.url_encode64
    |> binary_part(0, len)
  end
end
