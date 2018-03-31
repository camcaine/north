defmodule North.Client do
  @moduledoc """
  Client (or application) representation.
  """

  @type t :: %__MODULE__{
          id: binary,
          grant_types: MapSet.t(),
          public: boolean,
          redirect_uris: [String.t()],
          response_types: MapSet.t(),
          scopes: [String.t()],
          secret: binary | nil
        }

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
end
