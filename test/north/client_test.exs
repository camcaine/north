defmodule North.ClientTest do
  use ExUnit.Case, async: true
  alias North.Client

  def client(_context), do: [client: %Client{}]

  describe "Client" do
    setup :client

    test "default values", %{client: client} do
      assert is_nil(client.id)
      assert is_nil(client.secret)

      assert !!client.public

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
end
