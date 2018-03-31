defmodule North.ClientTest do
  use ExUnit.Case, async: true
  alias North.Client

  describe "Client" do
    setup do: [client: %Client{}]

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
end
