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

  @doc """
  Checks if `scope` matches against any scopes defined in `list`.
  """
  @callback matches?([scope], scope, opts :: Keyword.t()) :: boolean when scope: binary
end
