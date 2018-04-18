defmodule North.Hasher do
  @moduledoc """
  Password hashing behaviour.
  """

  @doc """
  Generates the hash of `password`.

  Implementation options can be passed in the second argument.
  """
  @callback hash(password :: binary, opts :: Keyword.t()) :: binary

  @doc """
  Verifies possible plaintext `password` is equivalent to hashed password `hash`.
  """
  @callback equivalent?(password :: binary, hash :: binary) :: boolean
end
