defmodule North.Plug do
  @moduledoc false

  alias Plug.Conn
  alias North.Client

  defp north_module(%Conn{} = conn), do: conn.private.north_module

  @doc """
  Fetches the client by `id` from the callback.
  """
  @spec fetch_client(Conn.t(), binary) :: {:ok, Client.t()} | {:error, :not_found}
  def fetch_client(%Conn{} = conn, id) when is_binary(id) do
    north_module(conn).fetch_client(id)
  end

  @doc """
  Extracts and decodes the basic auth header if present.

  Returns the username and password in a list provided in the request's
  Authorization header, if the request uses HTTP Basic Authentication.

  Otherwise returns an empty list.
  """
  @spec basic_auth(Conn.t()) :: [binary]
  def basic_auth(%Conn{} = conn) do
    with ["Basic " <> auth] <- Conn.get_req_header(conn, "authorization"),
         {:ok, decoded} <- Base.decode64(auth) do
      String.split(decoded, ":", parts: 2)
    else
      _ -> []
    end
  end
end
