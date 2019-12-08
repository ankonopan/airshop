defmodule WebApi.Endpoint do
  use Plug.Router

  def child_spec(opts) do
    Plug.Cowboy.child_spec(scheme: :http, plug: __MODULE__, options: opts)
  end

  def start_link(_opts),
    do: Plug.Cowboy.http(__MODULE__, port: 4001)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)
  forward("/cheapestOffer", to: WebApi.CheapestOffer)

  match _ do
    message = %{error: "Requested page not found!"} |> Poison.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, message)
  end
end
