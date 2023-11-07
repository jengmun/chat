defmodule ChatWeb.ChatRoomChannel do
  use Phoenix.Channel
  require ChatWeb.Constants

  @new_msg_event ChatWeb.Constants.ChannelEvents.new_message_event()

  def join("room:" <> _room_id, _params, socket) do
    {:ok, socket}
  end
end
