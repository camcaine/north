defmodule North.Plug.ClientTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias North.Plug.Client, as: CPlug
  alias North.{InvalidClientError, InvalidRequestError}

  defmodule Public do
    def fetch_client(id) when is_binary(id) do
      case id do
        "foo" -> {:ok, %North.Client{id: id, secret: "bar"}}
        _ -> {:error, :not_found}
      end
    end
  end

  defmodule Confidential do
    def fetch_client(id) when is_binary(id) do
      case id do
        "foo" -> {:ok, %North.Client{id: id, secret: "bar", public: false}}
        _ -> {:error, :not_found}
      end
    end
  end

  setup do: [id: "foo", secret: North.Hasher.Bcrypt.hash("bar")]

  describe "public client" do
    test "using basic auth", %{id: id} do
      conn =
        :post
        |> conn("/")
        |> put_req_header("authorization", basic_auth(id))
        |> put_private(:north_module, Public)
        |> CPlug.call([])

      assert %{id: ^id} = conn.assigns[:client]
    end

    test "using req params", %{id: id} do
      conn =
        :post
        |> conn("/", "client_id=#{id}")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")
        |> put_private(:north_module, Public)
        |> CPlug.call([])

      assert %{id: ^id} = conn.assigns[:client]
    end

    test "using invalid client id" do
      conn =
        :post
        |> conn("/")
        |> put_req_header("authorization", basic_auth("baz"))
        |> put_private(:north_module, Public)

      assert_raise InvalidClientError, fn -> CPlug.call(conn, []) end

      conn =
        :post
        |> conn("/", "client_id=baz")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")
        |> put_private(:north_module, Public)

      assert_raise InvalidClientError, fn -> CPlug.call(conn, []) end
    end
  end

  describe "confidential client" do
    test "using basic auth", %{id: id, secret: secret} do
      conn =
        :post
        |> conn("/")
        |> put_req_header("authorization", basic_auth(id, secret))
        |> put_private(:north_module, Confidential)
        |> CPlug.call([])

      assert %{id: ^id} = conn.assigns[:client]
    end

    test "using req params", %{id: id, secret: secret} do
      conn =
        :post
        |> conn("/", "client_id=#{id}&client_secret=#{secret}")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")
        |> put_private(:north_module, Confidential)
        |> CPlug.call([])

      assert %{id: ^id} = conn.assigns[:client]
    end

    test "using invalid client secret", %{id: id} do
      conn =
        :post
        |> conn("/")
        |> put_req_header("authorization", basic_auth(id, "qux"))
        |> put_private(:north_module, Confidential)

      assert_raise InvalidClientError, fn -> CPlug.call(conn, []) end

      conn =
        :post
        |> conn("/", "client_id=#{id}&client_secret=qux")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")
        |> put_private(:north_module, Confidential)

      assert_raise InvalidClientError, fn -> CPlug.call(conn, []) end
    end
  end

  describe "invalid request" do
    test "when content type not urlencoded", %{id: id} do
      conn =
        :post
        |> conn("/", "client_id=#{id}")

      assert_raise InvalidRequestError, fn -> CPlug.call(conn, []) end
    end

    test "using more than one authentication mechanism", %{id: id} do
      conn =
        :post
        |> conn("/", "client_id=#{id}")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")
        |> put_req_header("authorization", basic_auth(id))

      assert_raise InvalidRequestError, fn -> CPlug.call(conn, []) end
    end

    test "using malformed basic auth" do
      conn =
        :post
        |> conn("/")
        |> put_req_header("authorization", "Basic invalid:request")

      assert_raise InvalidRequestError, fn -> CPlug.call(conn, []) end
    end

    test "using basic auth missing the client id" do
      conn =
        :post
        |> conn("/")
        |> put_req_header("authorization", basic_auth(""))

      assert_raise InvalidRequestError, fn -> CPlug.call(conn, []) end
    end

    test "using req params missing the client id" do
      conn =
        :post
        |> conn("/")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")

      assert_raise InvalidRequestError, fn -> CPlug.call(conn, []) end
    end

    test "using req params with empty client id" do
      conn =
        :post
        |> conn("/", "client_id=")
        |> put_req_header("content-type", "application/x-www-form-urlencoded")

      assert_raise InvalidRequestError, fn -> CPlug.call(conn, []) end
    end
  end

  defp basic_auth(user, pass \\ "") do
    "Basic " <> Base.encode64(user <> ":" <> pass)
  end
end
