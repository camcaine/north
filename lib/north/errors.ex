defmodule North.InvalidRequestError do
  defexception plug_status: 400,
               error: "invalid_request",
               message: """
               The request is missing a required parameter, includes an
               unsupported parameter value (other than grant type),
               repeats a parameter, includes multiple credentials,
               utilizes more than one mechanism for authenticating the
               client, or is otherwise malformed.
               """
end

defmodule North.InvalidClientError do
  defexception plug_status: 400,
               error: "invalid_client",
               message: """
               Client authentication failed (e.g., unknown client, no
               client authentication included, or unsupported
               authentication method).
               """
end

defmodule North.InvalidGrantError do
  defexception plug_status: 400,
               error: "invalid_grant",
               message: """
               The provided authorization grant (e.g., authorization
               code, resource owner credentials) or refresh token is
               invalid, expired, revoked, does not match the redirection
               URI used in the authorization request, or was issued to
               another client.
               """
end

defmodule North.UnauthorizedClientError do
  defexception plug_status: 400,
               error: "unauthorized_client",
               message: """
               The authenticated client is not authorized to use this
               authorization grant type.
               """
end

defmodule North.UnsupportedGrantTypeError do
  defexception plug_status: 400,
               error: "unsupported_grant_type",
               message: """
               The authorization grant type is not supported by the
               authorization server.
               """
end

defmodule North.InvalidScopeError do
  defexception plug_status: 400,
               error: "invalid_scope",
               message: """
               The requested scope is invalid, unknown, malformed, or
               exceeds the scope granted by the resource owner.
               """
end
