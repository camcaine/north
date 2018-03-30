defmodule North.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule TestRouter do
    use Plug.Router

    plug(:match)
    plug(:dispatch)

    forward("/oauth", to: North.Router)
  end

  describe "mount" do
    test "authorize endpoint" do
      conn =
        :get
        |> conn("/oauth/authorize")
        |> North.RouterTest.TestRouter.call([])

      assert 200 = conn.status
      assert :sent = conn.state
    end

    test "token endpoint" do
      conn =
        :post
        |> conn("/oauth/token")
        |> North.RouterTest.TestRouter.call([])

      assert 200 = conn.status
      assert :sent = conn.state
    end

    test "catch all" do
      conn =
        :get
        |> conn("/oauth/missing")
        |> North.RouterTest.TestRouter.call([])

      assert 404 = conn.status
      assert :sent = conn.state
    end
  end
end
