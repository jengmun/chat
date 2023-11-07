defmodule ChatWeb.LandingLive do
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

  def handle_event("get_username", %{"username" => username}, socket) do
    cond do
      username === nil ->
        {:noreply, push_navigate(socket, to: "/login")}

      true ->
        socket =
          assign(socket,
            username: username
          )

        {:noreply, socket}
    end
  end
end
