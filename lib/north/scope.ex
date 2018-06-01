defmodule North.Scope do
  @moduledoc """
  Scope matching behaviour.

  `North.Scope.Wildcard` is the default scope matcher that comes
  out of the box and is flexible enough for most situations, but
  you can implement your own matcher if required.

  The definition of a match depends on the specific implementation.
  For example `North.Scope.Wildcard` uses glob style matching when
  deciding. This must be taken into account when providing clients
  with instructions on making scoped requests, and how the allowed
  client scopes are represented with the authorization server.
  """

  @type scope :: String.t()
  @type scope_list :: [scope]

  @doc """
  Checks if `scope` matches against any scopes defined in `list`.
  """
  @callback matches?(scope_list, scope, opts :: Keyword.t()) :: boolean

  @doc """
  Match `scopes2` against `scopes1` using the `matcher` behaviour.

  Returns a 2 element list of lists where the first includes scopes that
  matched and the second those that did not.

  The returned scopes are always from `scopes2` (essentially splitting `scopes2`).
  """
  @spec match(module, scope_list, scope_list) :: list(scope_list)
  def match(matcher, scopes1, scopes2) when is_list(scopes1) and is_list(scopes2) do
    scopes2
    |> Enum.split_with(&matcher.matches?(scopes1, &1))
    |> Tuple.to_list()
  end
end
