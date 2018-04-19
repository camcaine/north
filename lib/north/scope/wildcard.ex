defmodule North.Scope.Wildcard do
  @moduledoc """
  Scope behaviour that supports wildcard matching.
  """

  @wc "*"
  @behaviour North.Scope

  @doc """
  Matches using the `*` wildcard character.

  Wildcards can be used on either side of the match, with the left hand side
  taking precedence. The examples provide a clearer idea of what matches and
  what does not. Check the test suite for a more complete set of examples.

  ## Example

      iex> North.Scope.Wildcard.matches?(~w(foo.bar), "foo.bar")
      true

      iex> North.Scope.Wildcard.matches?(~w(foo.*), "foo.bar.baz")
      true

      iex> North.Scope.Wildcard.matches?(~w(foo.*), "foo")
      false

      iex> North.Scope.Wildcard.matches?(~w(foo.*.bar.*), "foo.*.bar.*.*.*")
      true

      iex> North.Scope.Wildcard.matches?(~w(foo.*.bar.*), "foo.baz.bar")
      false

  ## Options

  * `:delimiter` - The character used to delimit scope granularity.
    For example the scope: `user:profile` is delimited by the `:`
    (colon) character. Supported delimiters are: `.` `:` `,` `;`.
    The default is `.` (period).
  """
  @impl true
  def matches?(scopes, scope, opts \\ []) when is_list(scopes) and is_binary(scope) do
    splitter =
      opts
      |> Keyword.get(:delimiter, ".")
      |> scope_splitter()

    parts = splitter.(scope)
    Enum.any?(scopes, &do_match?(splitter.(&1), parts))
  end

  defp do_match?([], _), do: false
  defp do_match?(a, b) when length(a) > length(b), do: false

  defp do_match?([@wc | _], ["" | _]), do: false
  defp do_match?([@wc | []], _), do: true
  defp do_match?([@wc | t1], [_ | t2]), do: do_match?(t1, t2)

  defp do_match?([h | []], [h | []]), do: true
  defp do_match?([h | t1], [h | t2]), do: do_match?(t1, t2)

  defp do_match?(_, _), do: false

  defp scope_splitter(pattern) when pattern in ~w(. : , ;) do
    &String.split(&1, pattern)
  end

  defp scope_splitter(pattern) do
    raise ArgumentError,
      message: """
      cannot use #{inspect(pattern)} for scope delimitation.
      Use one of the supported delimiters (. : , ;) instead\
      """
  end
end
