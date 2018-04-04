defmodule North.Utils do
  @moduledoc false

  @doc false
  @spec map_keys(map, Keyword.t()) :: map
  def map_keys(map, key_map) when is_map(map) do
    for {key, map_key} <- key_map, map[map_key], into: %{}, do: {key, map[map_key]}
  end
end
