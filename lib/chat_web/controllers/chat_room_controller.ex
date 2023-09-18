defmodule ChatWeb.ChatRoomController do
  use ChatWeb, :controller
  import Jason

  def index(conn, _params) do
    struct = conn.body_params
    json_string = encode!(struct)
    IO.inspect("index::")
    IO.inspect(json_string)

    render(conn, :index)
  end

  # may be able to remove
  def create(conn, _params) do
    struct = conn.params
    json_string = encode!(struct)
    IO.inspect("create::")
    IO.puts(json_string)

    render(conn, :index)
  end
end
