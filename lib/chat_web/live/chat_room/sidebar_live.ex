defmodule ChatWeb.SidebarLive do
  require Logger
  use ChatWeb, :live_view
  require ChatWeb.Constants

  def mount(_params, session, socket) do
    %{"username" => username, "room" => room} = session

    {:ok, assign(socket, username: username, room: room, rooms: [])}
  end

  def handle_event("get_rooms", %{"rooms" => rooms}, socket) do
    IO.inspect(rooms, label: "Rooms")

    if rooms !== nil do
      {:noreply,
       assign(socket,
         rooms: rooms
       )}
    else
      {:noreply, socket}
    end
  end
end
