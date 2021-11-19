defmodule JobsWorldwide.Router do
  use Plug.Router

  import PlugEtf

  alias JobsWorldwide.API

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:etf], pass: ["application/x-erlang-binary"])
  plug(:dispatch)

  get "/" do
    send_etf(conn, 200, ["Hello", "World"])
  end

  get "/offers" do
    send_etf(conn, 200, API.get_offers())
  end

  get "/offers/:query" do
    query = URI.decode_query(query)
    send_etf(conn, 200, API.query_filter(query))
  end

  match _ do
    send_resp(conn, 404, "Nothing to see.")
  end
end
