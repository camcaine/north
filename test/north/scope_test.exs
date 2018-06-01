defmodule North.ScopeTest do
  use ExUnit.Case, async: true

  import North.Scope

  describe "match/3" do
    test "matching with wildcards" do
      matcher = North.Scope.Wildcard

      assert [[], []] = match(matcher, [], [])

      assert [~w(foo), []] = match(matcher, ~w(foo), ~w(foo))
      assert [[], ~w(foo)] = match(matcher, ~w(bar), ~w(foo))

      assert [~w(foo bar), ~w(baz)] = match(matcher, ~w(foo bar), ~w(foo bar baz))
      assert [~w(foo bar), ~w(baz)] = match(matcher, ~w(foo bar qux), ~w(foo bar baz))
    end
  end
end
