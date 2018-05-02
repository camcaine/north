defmodule North.Plug.Client do
  @moduledoc """
  Plug for fetching the `North.Client` from request credentials.

  Client credentials are sought from the authorization header
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
  > client credentials in the request-body...

  The resulting `North.Client` will be assigned to `conn.assigns` under
  the key `:client`.

  Any errors will be raised as either `North.InvalidRequestError` or
  `North.InvalidClientError`. It is up to downstream plugs to handle such
  exceptions (see `Plug.ErrorHandler`).
  """

  use Plug.Builder

  import North.{Plug, Utils}

  plug(Plug.Parsers, parsers: [:urlencoded])

  @keys ~w(id secret)

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, opts) do
    conn = super(conn, opts)

    with {:ok, credentials} <- fetch_credentials(conn),
         {:ok, id} <- Keyword.fetch(credentials, :id),
         {:ok, client} <- fetch_client(conn, id),
         true <- client.public || authenticate(client, credentials) do
      assign(conn, :client, client)
    else
      :error -> raise North.InvalidRequestError
      _error -> raise North.InvalidClientError
    end
  end

  defp fetch_credentials(conn) do
    case [:basic_auth, :req_params]
         |> Enum.map(&Task.async(fn -> parse(&1, conn) end))
         |> Enum.map(&Task.await/1) do
      [ok, []] when length(ok) > 0 -> {:ok, ok}
      [[], ok] when length(ok) > 0 -> {:ok, ok}
      _ -> :error
    end
  end

  defp parse(:basic_auth, conn) do
    for {k, v} <- Enum.zip(@keys, basic_auth(conn)), !empty?(v) do
      {String.to_atom(k), URI.decode_www_form(v)}
    end
  end

  defp parse(:req_params, conn) do
    for {"client_" <> k, v} when k in @keys <- conn.body_params, !empty?(v) do
      {String.to_atom(k), v}
    end
  end

  defp authenticate(client, credentials) do
    with {:ok, hash} <- Keyword.fetch(credentials, :secret) do
      North.Client.authenticate(client, hash)
    end
  end
end
