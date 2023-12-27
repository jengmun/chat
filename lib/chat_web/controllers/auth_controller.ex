defmodule ChatWeb.AuthController do
  use ChatWeb, :controller
  plug Ueberauth

  def request(conn, _params) do
    conn
  end

  def callback(%{assigns: %{ueberauth_failure: _error}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/auth/github")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_info = %{
      username: auth.info.nickname,
      email: auth.info.email,
      avatar: auth.info.image
    }

    conn =
      conn
      |> put_session(:user, user_info)
      |> put_resp_cookie(
        "user",
        user_info,
        sign: true
      )

    conn |> redirect(to: "/")
  end

  def require_auth(conn, _opts) do
    stored_user = fetch_cookies(conn, signed: ["user"]).cookies["user"]

    cond do
      conn |> get_session("user") !== nil ->
        conn

      stored_user !== nil ->
        conn
        |> put_session(:user, %{
          username: stored_user.username,
          email: stored_user.email,
          avatar: stored_user.avatar
        })

      true ->
        conn
        |> redirect(to: "/auth/github")
        |> halt()
    end
  end
end
