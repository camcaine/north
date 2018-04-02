defmodule North.URITest do
  use ExUnit.Case, async: true
  import North.URI

  describe "redirectable?/1" do
    test "all" do
      for uri <- ~w(example.com
                    example.com#foo=bar
                    https://example.com#foo=bar
                    https://example.com?foo=bar#baz=qux) do
        assert false === redirectable?(URI.parse(uri))
      end

      assert true === redirectable?(URI.parse("https://example.com?foo=bar"))
    end
  end

  describe "secure?/1" do
    test "all" do
      for uri <- ~w(http://localhost
                    http://test.localhost
                    https://example.com
                    ftp://authz) do
        assert true === secure?(URI.parse(uri))
      end

      assert false === secure?(URI.parse("http://example.com"))
    end
  end

  describe "localhost?/1" do
    test "all" do
      for uri <- ~w(https://localhost
                    https://localhost:1234
                    https://127.0.0.1:1234
                    https://127.0.0.1
                    https://test.localhost:1234
                    https://test.localhost) do
        assert true === localhost?(URI.parse(uri))
      end

      assert false === localhost?(URI.parse("https://foo.bar"))
    end
  end
end
