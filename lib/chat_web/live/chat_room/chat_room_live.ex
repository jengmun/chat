defmodule ChatWeb.ChatRoomLive do
  require Logger
  use ChatWeb, :live_view
  require ChatWeb.Constants

  @new_msg_event ChatWeb.Constants.ChannelEvents.new_message_event()

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        all_messages: [],
        room: "",
        username: "",
        form: to_form(%{})
      )

    {:ok, socket}
  end

  def handle_params(%{"room" => room}, _uri, socket) do
    ChatWeb.Endpoint.subscribe("room:" <> room)

    {:noreply,
     assign(socket,
       room: room
     )}
  end

  def handle_event("submit", %{"message" => message}, socket) do
    ChatWeb.Endpoint.broadcast!("room:" <> socket.assigns.room, @new_msg_event, %{
      data: %{
        sender: socket.assigns.username,
        recipient: socket.assigns.room,
        message: message
      }
    })

    {:noreply, socket}
  end

  def handle_event("item_from_session_storage", %{"username" => username}, socket) do
    {:noreply,
     assign(socket,
       username: username
     )}
  end

  def handle_info(msg, socket) do
    %{event: event} = msg

    case event do
      @new_msg_event ->
        %{sender: sender, recipient: recipient, message: message} = msg.payload.data

        {:noreply,
         assign(socket,
           all_messages:
             socket.assigns.all_messages ++
               [%{sender: sender, recipient: recipient, message: message}]
         )}
    end
  end
end
