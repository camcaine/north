defmodule North.Scope.WildcardTest do
  use ExUnit.Case, async: true

  describe "matches?/2" do
    import North.Scope.Wildcard

    test "with '*' delimiter raises" do
      assert_raise ArgumentError, fn ->
        matches?([], "foo", delimiter: "*")
      end
    end

    test "with '.' delimiter (default)" do
      assert false == matches?([], "foo")
      assert false == matches?([], "foo.bar")
      assert false == matches?([], "foo.bar.baz")

      scopes = ~w(*)
      assert true == matches?(scopes, "foo")
      assert true == matches?(scopes, "foo.bar")
      assert true == matches?(scopes, "foo.bar.baz")
      assert false == matches?(scopes, "")

      assert true == matches?(~w(foo), "foo")
      assert true == matches?(~w(foo.bar), "foo.bar")
      assert true == matches?(~w(foo.bar.baz), "foo.bar.baz")

      scopes = ~w(foo)
      assert true == matches?(scopes, "foo")
      assert false == matches?(scopes, "*")
      assert false == matches?(scopes, "foo.*.)")

      scopes = ~w(foo.*)
      assert true == matches?(scopes, "foo.bar")
      assert true == matches?(scopes, "foo.baz")
      assert true == matches?(scopes, "foo.bar.baz")
      assert false == matches?(scopes, "foo")

      scopes = ~w(foo.*.baz)
      assert true == matches?(scopes, "foo.*.baz")
      assert true == matches?(scopes, "foo.bar.baz")
      assert false == matches?(scopes, "foo..baz")
      assert false == matches?(scopes, "foo.baz")
      assert false == matches?(scopes, "foo")
      assert false == matches?(scopes, "foo.bar.bar")

      scopes = ~w(foo.*.bar.*)
      assert true == matches?(scopes, "foo.baz.bar.qux")
      assert true == matches?(scopes, "foo.baz.bar.bar.bar")
      assert true == matches?(scopes, "foo.*.bar.*.*.*")
      assert true == matches?(scopes, "foo.1.bar.1.2.3.4.5")
      assert false == matches?(scopes, "foo.baz.bar")
      assert false == matches?(scopes, "foo.baz.baz.bar.baz")

      scopes = ~w(foo.*.bar)
      assert true == matches?(scopes, "foo.bar.bar")
      assert false == matches?(scopes, "foo.bar.bar.bar")
      assert false == matches?(scopes, "foo..bar")
      assert false == matches?(scopes, "foo.bar..bar")

      scopes = ~w(foo.*.bar.*.baz.*)
      assert true == matches?(scopes, "foo.bar.bar.baz.baz.baz")
      assert true == matches?(scopes, "foo.bar.bar.baz.baz.baz.baz")
      assert false == matches?(scopes, "foo.*.*")
      assert false == matches?(scopes, "foo.*.bar")
      assert false == matches?(scopes, "foo.baz.*")
      assert false == matches?(scopes, "foo.baz.bar")
      assert false == matches?(scopes, "foo.b*.bar")
      assert false == matches?(scopes, "foo.bar.bar.baz.baz")
      assert false == matches?(scopes, "foo.bar.baz.baz.baz.bar")

      scopes = ~w(openid offline)
      assert true == matches?(scopes, "offline")
      assert true == matches?(scopes, "openid")
    end

    test "with ':' delimiter" do
      scopes = ~w(foo:*:bar:*:baz:*)
      assert true == matches?(scopes, "foo:bar:bar:baz:baz:baz", delimiter: ":")
      assert true == matches?(scopes, "foo:bar:bar:baz:baz:baz:baz", delimiter: ":")
      assert false == matches?(scopes, "foo:*:*", delimiter: ":")
      assert false == matches?(scopes, "foo:*:bar", delimiter: ":")
      assert false == matches?(scopes, "foo:baz:*", delimiter: ":")
      assert false == matches?(scopes, "foo:baz:bar", delimiter: ":")
      assert false == matches?(scopes, "foo:b*:bar", delimiter: ":")
      assert false == matches?(scopes, "foo:bar:bar:baz:baz", delimiter: ":")
      assert false == matches?(scopes, "foo:bar:baz:baz:baz:bar", delimiter: ":")
    end
  end
end
