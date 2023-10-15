defmodule ChatWeb.ChatLive do
  require Logger
  use ChatWeb, :live_view
  require ChatWeb.Constants

  @new_msg_event ChatWeb.Constants.ChannelEvents.new_message_event()

  def mount(_params, _session, socket) do
    newRoomId = Integer.to_string(:rand.uniform(4_294_967_296), 32)

    socket =
      assign(socket,
        all_messages: [],
        room: newRoomId,
        username: ""
      )

    {:ok, socket}
  end
end
