defmodule WebApi.CheapestOffer do
  use Plug.Router
  use Plug.ErrorHandler

  plug(:match)
  plug(:dispatch)

  get "/" do
    verify_query_params(conn)

    %{"origin" => dep, "destination" => arr, "departureDate" => date} = conn.query_params

    case WebApi.AirShopWrapper.call({:cheapestOffer, dep, arr, date}) do
      {:error, error} ->
        message = %{error: error} |> Poison.encode!()

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(502, message)

      response ->
        message = response |> Poison.encode!()

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, message)
    end
  end

  @doc """
  Validates that required query params are present
  """
  defp verify_query_params(conn) do
    params =
      conn.query_params
      |> Map.take(["origin", "destination", "departureDate"])

    unless Map.has_key?(params, "origin") &&
             Map.has_key?(params, "destination") &&
             Map.has_key?(params, "departureDate") do
      throw(:invalid_params)
    end
  end

  @doc """
  Returns a JSON error response with Invalid Params
  """
  defp handle_errors(conn, %{kind: :throw, reason: :invalid_params, stack: _stack}) do
    message = %{error: "Invalid params!"} |> Poison.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, message)
  end

  @doc """
  Returns the error information over the API endpoint.
  On production environment it returns an obscured "Internal Error"
  On other environments it returns the error's reason
  """
  defp handle_errors(conn, %{kind: _, reason: reason, stack: _stack}) do
    message =
      case Mix.env() do
        :dev ->
          %{error: reason} |> Poison.encode!()

        :test ->
          %{error: reason} |> Poison.encode!()

        _ ->
          %{error: "Internal Error"} |> Poison.encode!()
      end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, message)
  end
end
