defmodule North.Hasher.Bcrypt do
  @moduledoc false

  @behaviour North.Hasher

  @impl true
  defdelegate hash(password, opts \\ []),
    to: Bcrypt,
    as: :hash_pwd_salt

  @impl true
  defdelegate verify(password, hash),
    to: Bcrypt,
    as: :verify_pass
end
