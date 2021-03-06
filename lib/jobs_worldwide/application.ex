defmodule JobsWorldwide.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: JobsWorldwide.Router, port: 3000}
    ]

    opts = [strategy: :one_for_one, name: JobsWorldwide.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
