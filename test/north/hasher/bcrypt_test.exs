defmodule North.Hasher.BcryptTest do
  use ExUnit.Case, async: true
  import North.Hasher.Bcrypt

  setup do: [hash: hash("foo", log_rounds: 4)]

  test "hash/2", %{hash: hash} do
    assert is_binary(hash)
    assert "foo" !== hash
  end

  test "equivalent?/2", %{hash: hash} do
    assert is_binary(hash)
    assert equivalent?("foo", hash)
    refute equivalent?("bar", hash)
  end
end
