defmodule North.Plug.ClientCredentialsTest do
  use ExUnit.Case, async: true
  use Plug.Test

  setup do
    [id: "foo", secret: "bar"]
  end

  describe "basic auth" do
    test "credentials", %{id: id, secret: secret} do
      conn =
        :post
        |> conn("/", "client_id=baz&client_secret=qux")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")
        |> put_req_header("authorization", "Basic " <> encode(id, secret))
        |> North.Plug.ClientCredentials.call([])

      assert %{id: ^id, secret: ^secret} = conn.assigns.client
    end

    test "empty secret", %{id: id} do
      conn =
        :post
        |> conn("/")
        |> put_req_header("authorization", "Basic " <> encode(id, ""))
        |> North.Plug.ClientCredentials.call([])

      assert %{id: ^id, secret: nil} = conn.assigns.client
    end

    test "missing id", %{secret: secret} do
      assert_raise ArgumentError, fn ->
        :post
        |> conn("/")
        |> put_req_header("authorization", "Basic " <> encode("", secret))
        |> North.Plug.ClientCredentials.call([])
      end
    end
  end

  describe "req params" do
    # Also tests basic auth has falling through
    test "credentials", %{id: id, secret: secret} do
      conn =
        :post
        |> conn("/", "client_id=#{id}&client_secret=#{secret}")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")
        |> North.Plug.ClientCredentials.call([])

      assert ^id = conn.assigns.client.id
      assert ^secret = conn.assigns.client.secret
    end

    test "empty secret", %{id: id} do
      conn =
        :post
        |> conn("/", "client_id=#{id}&client_secret=")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")
        |> North.Plug.ClientCredentials.call([])

      assert %{id: ^id, secret: nil} = conn.assigns.client
    end

    test "missing secret", %{id: id} do
      conn =
        :post
        |> conn("/", "client_id=#{id}")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")
        |> North.Plug.ClientCredentials.call([])

      assert %{id: ^id, secret: nil} = conn.assigns.client
    end

    test "empty id", %{secret: secret} do
      assert_raise ArgumentError, fn ->
        :post
        |> conn("/", "client_id=&client_secret=#{secret}")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")
        |> North.Plug.ClientCredentials.call([])
      end
    end

    test "missing id", %{secret: secret} do
      assert_raise ArgumentError, fn ->
        :post
        |> conn("/", "client_secret=#{secret}")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")
        |> North.Plug.ClientCredentials.call([])
      end
    end
  end

  defp encode(user, pass) do
    Base.encode64(user <> ":" <> pass)
  end
end
