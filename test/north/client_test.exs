defmodule North.ClientTest do
  use ExUnit.Case, async: true
  alias North.Client

  def client(_context), do: [client: %Client{}]

  describe "Client" do
    setup :client

    test "default values", %{client: client} do
      assert is_nil(client.id)
      assert is_nil(client.secret)

      assert client.public

      assert [] = client.redirect_uris
      assert [] = client.scopes

      assert ~w(code) = MapSet.to_list(client.response_types)
      assert ~w(authorization_code) = MapSet.to_list(client.grant_types)
    end
  end

  describe "respond_to?/2" do
    setup :client

    test "with subset of response types", %{client: client} do
      assert true === Client.respond_to?(client, ~w(code))

      set = MapSet.new(~w(code token))
      assert true === Client.respond_to?(%{client | response_types: set}, ~w(token))
    end

    test "with non-subset of response types", %{client: client} do
      assert false === Client.respond_to?(client, [])
      assert false === Client.respond_to?(client, ~w(unknown))
      assert false === Client.respond_to?(client, ~w(code token))
    end
  end

  describe "match_redirect_uri/2" do
    setup :client

    test "with zero client redirect uris", %{client: client} do
      assert :error = Client.match_redirect_uri(client)
      assert :error = Client.match_redirect_uri(client, "")
      assert :error = Client.match_redirect_uri(client, "https://example.com/cb")
    end

    test "with one client redirect uris", %{client: client} do
      client = %{client | redirect_uris: ~w(https://example.com/cb)}

      assert {:ok, %URI{}} = Client.match_redirect_uri(client)
      assert {:ok, %URI{}} = Client.match_redirect_uri(client, "https://example.com/cb")

      assert :error = Client.match_redirect_uri(client, "")
      assert :error = Client.match_redirect_uri(client, "https://example.com/cb1")
    end

    test "with many client redirect uris", %{client: client} do
      client = %{client | redirect_uris: ~w(https://example.com/cb1
                                            https://example.com/cb2
                                            https://example.com/cb3)}

      assert {:ok, %URI{}} = Client.match_redirect_uri(client, "https://example.com/cb1")
      assert {:ok, %URI{}} = Client.match_redirect_uri(client, "https://example.com/cb2")
      assert {:ok, %URI{}} = Client.match_redirect_uri(client, "https://example.com/cb3")

      assert :error = Client.match_redirect_uri(client)
      assert :error = Client.match_redirect_uri(client, "")
      assert :error = Client.match_redirect_uri(client, "https://example.com/cb")
    end

    test "case insensitivity", %{client: client} do
      lowercase = "https://example.com/cb"
      uppercase = "https://example.com/CB"

      # with 1

      client = %{client | redirect_uris: [uppercase]}
      {:ok, uri} = Client.match_redirect_uri(client, lowercase)

      assert ^lowercase = URI.to_string(uri)

      # with n

      client = %{client | redirect_uris: [lowercase, uppercase]}
      {:ok, uri} = Client.match_redirect_uri(client, uppercase)

      assert ^uppercase = URI.to_string(uri)
    end
  end
end
