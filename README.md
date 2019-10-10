# ExAliyun

Aliyun client for elixir. Only RPC client for now.

## Installation

Use git repo

```elixir
def deps do
  [
    {:ex_aliyun, git: "https://github.com/j-deng/ex_aliyun.git"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)

## Usage

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
