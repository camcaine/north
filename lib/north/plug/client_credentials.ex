defmodule North.Plug.ClientCredentials do
  @moduledoc """
  Plug for extracting client credentials.

  Attempts to extract client credentials from the authorization header
  or the request body if no authorization header is provided.
  As per <https://tools.ietf.org/html/rfc6749#section-3.2.1>:

  > Clients in possession of a client password MAY use the HTTP Basic
  > authentication scheme as defined in [RFC2617] to authenticate with
  > the authorization server.  The client identifier is encoded using the
  > "application/x-www-form-urlencoded" encoding algorithm per
  > Appendix B, and the encoded value is used as the username; the client
  > password is encoded using the same algorithm and used as the
  > password.  The authorization server MUST support the HTTP Basic
  > authentication scheme for authenticating clients that were issued a
  > client password.
  >
  > Alternatively, the authorization server MAY support including the
  > client credentials in the request-body using the following
  > parameters:
  >
  > client_id –
  >   The client identifier issued to the client during
  >   the registration process described by Section 2.2.
  >
  > client_secret –
  >   The client secret. The client MAY omit the
  >   parameter if the client secret is an empty string.
  """

  use Plug.Builder

  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(:basic_auth)
  plug(:req_params)

  @doc false
  def basic_auth(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> auth] ->
        [id, secret] = parse!(auth)

        conn
        |> assign(:client, map_credentials(id, secret))
        |> halt()

      _ ->
        conn
    end
  end

  defp parse!(encoded) do
    try do
      encoded
      |> Base.decode64!()
      |> URI.decode_www_form()
      |> String.split(":", parts: 2)
    rescue
      e ->
        # FIXME: make custom error (InvalidRequestError)
        e
    end
  end

  @doc false
  def req_params(conn, _opts) do
    # Plug.Parsers decoded www-form-urlencoded params upstream
    assign(
      conn,
      :client,
      map_credentials(
        Map.get(conn.body_params, "client_id", ""),
        Map.get(conn.body_params, "client_secret")
      )
    )
  end

  defp map_credentials(id, secret \\ nil)

  defp map_credentials("", _) do
    # FIXME: make custom error (InvalidRequestError)
    raise ArgumentError, """
    client_id in the HTTP Authorization \
    header or HTTP POST body is missing
    """
  end

  defp map_credentials(id, ""), do: map_credentials(id)
  defp map_credentials(id, secret), do: %{id: id, secret: secret}
end
