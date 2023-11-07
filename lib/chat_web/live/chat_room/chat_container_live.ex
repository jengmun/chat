defmodule ChatWeb.ChatContainerLive do
  require Logger
  use ChatWeb, :live_view
  require ChatWeb.Constants

  @join_room_event ChatWeb.Constants.ChannelEvents.join_room_event()

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        room: "",
        username: ""
      )

    {:ok, socket}
  end

  # Called before handle_event
  def handle_params(%{"room" => room}, _uri, socket) do
    if room != "" do
      socket =
        assign(socket,
          room: room
        )

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("get_username", %{"username" => username}, socket) do
    cond do
      username === nil ->
        {:noreply, push_navigate(socket, to: "/login")}

      socket.assigns.room !== "" ->
        {:ok, datetime} = DateTime.now("Asia/Singapore", Tz.TimeZoneDatabase)

        ChatWeb.Endpoint.broadcast!("room:" <> socket.assigns.room, @join_room_event, %{
          data: %{
            sender: nil,
            recipient: socket.assigns.room,
            message: "#{username} has just joined the room",
            datetime: datetime
          }
        })

        socket =
          assign(socket,
            username: username
          )

        {:noreply,
         push_event(socket, "session-storage", %{
           type: :join_room,
           data: %{room: socket.assigns.room}
         })}

      true ->
        socket =
          assign(socket,
            username: username
          )

        {:noreply, socket}
    end
  end
end
