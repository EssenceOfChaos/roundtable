defmodule Roundtable.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy,
       scheme: :http,
       plug: Roundtable.Router,
       options: [port: Application.get_env(:roundtable, :port)]},
      {
        Mongo,
        [
          name: :mongo,
          database: Application.get_env(:roundtable, :database),
          pool_size: Application.get_env(:roundtable, :pool_size)
        ]
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Roundtable.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
