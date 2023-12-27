defmodule ChatWeb.ChatContainerLive do
  require Logger
  use ChatWeb, :live_view
  require ChatWeb.Constants

  @join_room_event ChatWeb.Constants.ChannelEvents.join_room_event()

  def mount(_params, session, socket) do
    user = session["user"]

    socket =
      assign(socket,
        room: "",
        user: %{username: user.username, email: user.email, avatar: user.avatar}
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
end
