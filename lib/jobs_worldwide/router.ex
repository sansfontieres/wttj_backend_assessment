defmodule JobsWorldwide.Router do
  use Plug.Router

  import PlugEtf

  alias JobsWorldwide.API

  plug(Plug.Logger)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:etf, :json],
    pass: ["application/x-erlang-binary", "text/*"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/" do
    send_etf(conn, 200, ["Hello", "World"])
  end

  get "/offers" do
    send_etf(conn, 200, API.get_offers())
  end

  get "/offers/:query" do
    query = URI.decode_query(query)
    body = API.query_filter(query)

    if get_req_header(conn, "accept") == ["application/x-erlang-binary"] do
      send_etf(conn, 200, body)
    else
      json = API.json_serialize(body)
      send_resp(conn, 200, json)
    end
  end

  match _ do
    send_resp(conn, 404, "Nothing to see.")
  end
end
