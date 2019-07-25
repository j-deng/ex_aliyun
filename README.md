# ExAliyun

Aliyun client for elixir. Only RPC client for now.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_aliyun` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_aliyun, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_aliyun](https://hexdocs.pm/ex_aliyun).

## Usage

```elixir
alias ExAliyun.Client.RPC

client = %RPC{
  endpoint: "https://dysmsapi.aliyuncs.com",
  access_key_id: "<access_key_id>",
  access_key_secret: "<access_key_secret>",
  api_version: "2017-05-25",
}

# example for send sms
params = %{
  "RegionId" => "cn-hangzhou",
  "PhoneNumbers" => "1865086****",
  "SignName" => "SignName",
  "TemplateCode" => "SMS_11111",
  "TemplateParam" => "{\"code\":123123}"
}
RPC.request(client, "SendSms", params)
```
