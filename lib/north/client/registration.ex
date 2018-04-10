defprotocol North.Client.Registration do
  @moduledoc """
  Protocol for deriving a `North.Client`.

  This protocol is used as a bridge between your client data structure
  and North's. This decoupling means North does not need to know about
  about your client management system (signup/storage etc). Instead it
  is only concerned with registering valid clients.

  ## Deriving

  North expects an `@derive` struct. North looks for recognisable keys
  and ignores those it does not. For example:

      defmodule MyClient do
        @derive North.Client.Registration
        defstruct [:id]
      end

  #### Custom Mapping

  If your struct has different keys than North expects, you can pass a
  keyword list of mappings. For example, instead of an `:id` field you
  have `:uuid`:

      defmodule MyClient do
        @derive {North.Client.Registration, id: :uuid}
        defstruct [:uuid]
      end

  The `:id` key is required, all others are optional.
  See `t:North.Client.t/0` for details of valid keys.
  """

  @fallback_to_any true

  @doc """
  Maps `other` to a client.
  """
  @spec register(any) :: North.Client.t()
  def register(other)
end

defimpl North.Client.Registration, for: Any do
  alias North.Client.Registration

  defmacro __deriving__(module, struct, opts) do
    id_key = Keyword.get(opts, :id, :id)

    unless Map.has_key?(struct, id_key) do
      raise ArgumentError,
        message: """
        can't derive North.Client.Registration for struct #{inspect(module)} \
        because it does not have key #{inspect(id_key)}. Please pass the :id \
        key when deriving
        """
    end

    quote do
      defimpl Registration, for: unquote(module) do
        def register(%{unquote(id_key) => id}) when not is_binary(id) do
          raise ArgumentError,
            message: """
            can't derive North.Client.Registration for struct #{inspect(unquote(module))} \
            because key #{inspect(unquote(id_key))} is expected to be a binary
            """
        end

        def register(%{unquote(id_key) => id} = other) do
          struct(North.Client, map_fields(Map.from_struct(other), unquote(opts)))
        end

        defp map_fields(map, field_map) do
          Map.merge(map, North.Utils.map_keys(map, field_map))
        end
      end
    end
  end

  def register(%_{} = struct) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: struct,
      description: """
      North.Client.Registration protocol must be derived directly. \
      Deriving looks for keys it recognises. Only :id is required. \
      Other keys are optional.

          @derive North.Client.Registration
          defstruct ...

      Or using custom key mapping:

          @derive {North.Client.Registration, id: :uuid}
          defstruct ...

      See North.Client for details of valid keys.
      """
  end

  def register(any) do
    raise Protocol.UndefinedError, protocol: @protocol, value: any
  end
end

defimpl North.Client.Registration, for: List do
  def register(list) do
    cond do
      Keyword.keyword?(list) ->
        struct!(North.Client, list)

      true ->
        raise Protocol.UndefinedError, protocol: @protocol, value: list
    end
  end
end
