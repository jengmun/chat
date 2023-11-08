defmodule ChatWeb.ChatRoomChannel do
  use Phoenix.Channel
  require ChatWeb.Constants

  def join("room:" <> _room_id, _params, socket) do
    {:ok, socket}
  end
end
