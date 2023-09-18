defmodule ChatWeb.ChatRoomChannel do
  use Phoenix.Channel
  require ChatWeb.Constants

  @new_msg_event ChatWeb.Constants.new_message_event()
  @lobby ChatWeb.Constants.Channels.lobby()

  def join(@lobby, _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in(@new_msg_event, %{"body" => body}, socket) do
    broadcast!(socket, @new_msg_event, %{body: body})

    {:noreply, socket}
  end
end
