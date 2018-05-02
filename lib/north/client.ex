defmodule North.Client do
  @moduledoc """
  Client (or application) representation.
  """

  @type t :: %__MODULE__{
          id: binary,
          grant_types: MapSet.t(),
          public: boolean,
          redirect_uris: [String.t(), ...],
          response_types: MapSet.t(),
          scopes: [String.t()],
          secret: binary | nil
        }

  @enforce_keys [:id]
  defstruct id: nil,
            public: true,
            # As per <https://tools.ietf.org/html/rfc7591#section-2>:
            # > If omitted, the default behavior is that the client
            # > will use only the "authorization_code" grant type.
            grant_types: MapSet.new(~w(authorization_code)),
            redirect_uris: [],
            # As per <https://tools.ietf.org/html/rfc7591#section-2>:
            # > If omitted, the default is that the client
            # > will use only the "code" response type.
            response_types: MapSet.new(~w(code)),
            scopes: [],
            secret: nil

  @doc """
  Callback to fetch a client by `id`.

  Must be implemented to identify clients from incoming requests. This should
  be used in conjunction with the `North.Client.Registration` protocol and the
  `register/1` helper:

      @derive North.Client.Registration
      defstruct ...

      @impl North.Client
      def fetch_client(id) when is_binary(id) do
        case Repo.get(MyApp.Client, id) do
          nil -> {:error, :not_found}
          cli -> {:ok, North.Client.register(cli)}
        end
      end

  Must return either `{:ok, client}` or `{:error, :not_found}`.
  """
  @callback fetch_client(id :: binary) :: {:ok, t} | {:error, :not_found}

  @doc """
  Convenience for deriving a client from `struct`.

  `struct` must implement the `North.Client.Registration` protocol.
  """
  @spec register(struct) :: t
  defdelegate register(struct), to: North.Client.Registration

  @doc """
  Verifies the `client` secret against supplied `hash`.
  """
  @spec authenticate(t, binary) :: boolean
  def authenticate(%__MODULE__{} = client, hash) when is_binary(hash) do
    North.Hasher.Bcrypt.verify(client.secret, hash)
  end

  @doc """
  Fetches client by `id`.

  Where `id` is the client id (typically passed in requests). Expects a `:from`
  keyword to be the module conforming to `North.Client` behaviour. For example:

      fetch_client("123", from: MyApp.Auth)
  """
  @spec fetch_client(binary, Keyword.t()) :: {:ok, t} | {:error, term}
  def fetch_client(id, opts \\ []) when is_binary(id) do
    Keyword.fetch!(opts, :from).fetch_client(id)
  end

  @doc """
  Checks if `client` can respond to `response_type`.

  Returns `true` when `response_type` is a subset of `client.response_types`.
  """
  @spec respond_to?(t, [String.t(), ...]) :: boolean
  def respond_to?(_client, []), do: false

  def respond_to?(%__MODULE__{} = client, response_type) when is_list(response_type) do
    response_type
    |> MapSet.new()
    |> MapSet.subset?(client.response_types)
  end

  @doc """
  Matches `uri` against those registered to `client`.

  As per <https://tools.ietf.org/html/rfc6749#section-3.1.2.3>:

  > If multiple redirection URIs have been registered, if only part of
  > the redirection URI has been registered, or if no redirection URI has
  > been registered, the client MUST include a redirection URI with the
  > authorization request using the "redirect_uri" request parameter.

  > When a redirection URI is included in an authorization request, the
  > authorization server MUST compare and match the value received
  > against at least one of the registered redirection URIs (or URI
  > components) as defined in [RFC3986] Section 6, if any redirection
  > URIs were registered.  If the client registration included the full
  > redirection URI, the authorization server MUST compare the two URIs
  > using simple string comparison as defined in [RFC3986] Section 6.2.1.

  ### Employs countermeasure:

  As per <https://tools.ietf.org/html/rfc6819#section-4.4.1.7>
  at least one redirect URI must be pre-registered:
  > The authorization server may also enforce the usage and validation
  > of pre-registered redirect URIs (see Section 5.2.3.5).  This will
  > allow for early recognition of authorization "code" disclosure to
  > counterfeit clients.

  ### Note:

  In the case of the trying to match against a missing redirect uri sent
  as part an authorization request, the `uri` should be ommited (same as
  passing as `nil`) rather than passing an empty string. An empty string
  will always result in `:error` being returned.

  This function does NOT perform any URI validation (e.g. HTTPS) other
  than checking for the validity of it's use in redirection.

  Successful macthes include a single valid `t:URI.t/0`.
  """
  @spec match_redirect_uri(t, String.t() | nil) :: {:ok, URI.t()} | :error
  def match_redirect_uri(%__MODULE__{} = client, uri \\ nil) do
    case {client.redirect_uris, uri} do
      {[], _} ->
        :error

      {_, ""} ->
        :error

      {[uri], nil} ->
        parse_redirect_uri(uri)

      {uris, uri} when not is_nil(uri) ->
        with uri when is_binary(uri) <- find_redirect_uri(uris, uri) do
          parse_redirect_uri(uri)
        end

      {_, _} ->
        :error
    end
  end

  defp parse_redirect_uri(uri) do
    uri = URI.parse(uri)

    cond do
      North.URI.redirectable?(uri) -> {:ok, uri}
      true -> :error
    end
  end

  defp find_redirect_uri(uris, uri) do
    uris
    |> Enum.map(&String.downcase/1)
    |> Enum.find_value(:error, fn v -> v === String.downcase(uri) && uri end)
  end
end
