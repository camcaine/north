defmodule North.Client.RegistrationTest do
  use ExUnit.Case, async: true

  alias North.Client
  alias North.Client.Registration

  defmodule Primary do
    defstruct id: "primary"
  end

  defmodule Derived do
    @derive Registration
    defstruct id: "derived", unknown: nil
  end

  defmodule DerOpts do
    @derive {Registration, id: :uuid, secret: :password}
    defstruct uuid: "deropts", id: "overriden", password: "password"
  end

  describe "impl for any" do
    test "derive" do
      assert %Client{id: "derived"} = register(%Derived{})
      assert %Client{id: "deropts", secret: "password"} = register(%DerOpts{})

      assert_raise ArgumentError, ~r[is expected to be a binary], fn ->
        register(%Derived{id: nil})
      end
    end

    test "fallback to" do
      assert_raise Protocol.UndefinedError, ~r[protocol must be derived], fn ->
        register(%Primary{})
      end

      assert_raise Protocol.UndefinedError, fn -> register(%{}) end
      assert_raise Protocol.UndefinedError, fn -> register({1}) end
      assert_raise Protocol.UndefinedError, fn -> register("1") end
      assert_raise Protocol.UndefinedError, fn -> register(123) end
    end
  end

  describe "impl for list" do
    test "keyword" do
      assert %Client{id: 1} = register(id: 1)

      assert_raise KeyError, fn -> register(uuid: 1) end
      assert_raise Protocol.UndefinedError, fn -> register([1]) end
      assert_raise ArgumentError, ~r[the following keys must also be given.*:id], fn ->
        register([])
      end
    end
  end

  defp register(other), do: Registration.register(other)
end
