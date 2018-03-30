defmodule North.Router do
  @moduledoc """
  Micro-router to support OAuth2 and OpenID endpoints.

  This `Plug` based router is the recommended way to mount the standard
  endpoints with minimal fuss. Mount from a desired location in your
  current router:

  ```
  Plug.Router.forward "/oauth", to: North.Router
  ```

  ## Paths

  The router provides OAuth 2.0 standard endpoints as per
  <https://tools.ietf.org/html/rfc6749#section-3>. Using the above mount
  would yield the following routes:

  * `GET /oauth/authorize` - used by the client to obtain authorization
    from the resource owner via user-agent redirection.
  * `POST /oauth/token` - used by the client to exchange an authorization
    grant for an access token, typically with client authentication.

  These paths cannot be modified at the current time.
  """

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get("/authorize", do: send_resp(conn, 200, "authorize"))
  post("/token", do: send_resp(conn, 200, "token"))

  match _ do
    send_resp(conn, 404, "not found")
  end
end
