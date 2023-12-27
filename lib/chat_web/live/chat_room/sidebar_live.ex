defmodule ChatWeb.SidebarLive do
  require Logger
  use ChatWeb, :live_view
  require ChatWeb.Constants

  @join_room_event ChatWeb.Constants.ChannelEvents.join_room_event()

  def mount(_params, session, socket) do
    user = session["user"]
    room = session["room"]

    socket =
      assign(socket,
        user: %{username: user.username, email: user.email, avatar: user.avatar},
        room: room,
        rooms: []
      )

    {:ok, socket}
  end

  def handle_event("get_rooms", %{"rooms" => rooms}, socket) do
    if rooms !== nil do
      {:noreply,
       assign(socket,
         rooms: rooms
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("create_room", _params, socket) do
    new_room = Integer.to_string(:rand.uniform(4_294_967_296), 32)

    {:ok, datetime} = DateTime.now("Asia/Singapore", Tz.TimeZoneDatabase)

    ChatWeb.Endpoint.broadcast!("room:" <> new_room, @join_room_event, %{
      data: %{
        sender: nil,
        room: new_room,
        message: "#{socket.assigns.user.username} has just joined the room",
        datetime: datetime
      }
    })

    socket =
      assign(
        socket,
        rooms: [new_room] ++ socket.assigns.rooms
      )
      |> push_event("join-room", %{
        data: %{room: new_room}
      })
      |> push_event("getRooms", %{})
      |> redirect(to: "/" <> new_room)

    {:noreply, socket}
  end
end
