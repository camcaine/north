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
end
