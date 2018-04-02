defmodule North.URI do
  @moduledoc """
  URI utilities.

  Functions wrapping `URI`. Mostly used for redirect URI introspection.
  """

  @doc """
  Validates the URI can be used for redirection.

  As per https://tools.ietf.org/html/rfc6749#section-3.1.2:

  > The redirection endpoint URI MUST be an absolute URI as defined by
  > [RFC3986] Section 4.3. The endpoint URI MAY include an
  > "application/x-www-form-urlencoded" formatted (per Appendix B) query
  > component ([RFC3986] Section 3.4), which MUST be retained when adding
  > additional query parameters.  The endpoint URI MUST NOT include a
  > fragment component.
  """
  @spec redirectable?(URI.t()) :: boolean
  def redirectable?(%URI{fragment: nil, scheme: scheme}) when is_binary(scheme), do: true
  def redirectable?(_uri), do: false

  @doc """
  Checks if the URI is secure.

  When secure is not using HTTP (unless running on localhost).
  """
  @spec secure?(URI.t()) :: boolean
  def secure?(%URI{scheme: "http"} = uri), do: localhost?(uri)
  def secure?(_uri), do: true

  @doc """
  Checks if the URI is localhost.
  """
  @spec localhost?(URI.t()) :: boolean
  def localhost?(%URI{host: nil}), do: false
  def localhost?(%URI{host: "127.0.0.1"}), do: true
  def localhost?(%URI{host: host}), do: String.ends_with?(host, "localhost")
end
