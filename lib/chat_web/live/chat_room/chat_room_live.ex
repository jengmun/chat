defmodule ChatWeb.ChatRoomLive do
  require Logger
  use ChatWeb, :live_view
  require ChatWeb.Constants
  require Ecto.Query

  @new_msg_event ChatWeb.Constants.ChannelEvents.new_message_event()
  @join_room_event ChatWeb.Constants.ChannelEvents.join_room_event()
  @user_typing_event ChatWeb.Constants.ChannelEvents.user_typing_event()
  @user_stop_typing_event ChatWeb.Constants.ChannelEvents.user_stop_typing_event()

  def mount(_params, session, socket) do
    %{"username" => username, "room" => room} = session

    all_db_messages = Chats.ChatMessage |> Ecto.Query.where(room: ^room) |> Chats.Repo.all()

    all_messages =
      Enum.map(all_db_messages, fn msg ->
        {:ok, new_datetime} = DateTime.from_unix(msg.datetime)

        %{msg | datetime: new_datetime}
      end)

    socket =
      assign(socket,
        all_messages: all_messages,
        room: room,
        username: username,
        users_typing: [],
        form: to_form(%{}),
        input_value: ""
      )

    if room !== "" do
      ChatWeb.Endpoint.subscribe("room:" <> room)

      {:ok,
       push_event(socket, "session-storage", %{
         type: :join_room,
         data: %{room: room}
       })}
    else
      {:ok, socket}
    end
  end

  def terminate(params, socket) do
    case params do
      {:shutdown, reason} when reason == :left or reason == :closed ->
        if(socket.assigns.username !== "") do
          {:ok, datetime} = DateTime.now("Asia/Singapore", Tz.TimeZoneDatabase)

          ChatWeb.Endpoint.broadcast!("room:" <> socket.assigns.room, @new_msg_event, %{
            data: %{
              sender: nil,
              room: socket.assigns.room,
              message: "#{socket.assigns.username} has just left the room",
              datetime: datetime
            }
          })
        end

      _ ->
        {:ok, socket}
    end
  end

  def handle_event("submit", %{"message" => message}, socket) do
    if message == "" do
      {:noreply, socket}
    else
      {:ok, datetime} = DateTime.now("Asia/Singapore", Tz.TimeZoneDatabase)

      ChatWeb.Endpoint.broadcast!("room:" <> socket.assigns.room, @new_msg_event, %{
        data: %{
          sender: socket.assigns.username,
          room: socket.assigns.room,
          message: message,
          datetime: datetime
        }
      })

      handle_typing_event(
        socket.assigns.room,
        socket.assigns.users_typing,
        socket.assigns.username,
        ""
      )

      db_data = %Chats.ChatMessage{
        sender: socket.assigns.username,
        room: socket.assigns.room,
        message: message,
        datetime: DateTime.to_unix(datetime)
      }

      Chats.Repo.insert!(db_data)

      {:noreply, assign(socket, input_value: "")}
    end
  end

  def handle_event("change", %{"message" => message}, socket) do
    handle_typing_event(
      socket.assigns.room,
      socket.assigns.users_typing,
      socket.assigns.username,
      message
    )

    {:noreply, assign(socket, input_value: message)}
  end

  def handle_info(msg, socket) do
    %{event: event, payload: %{data: data}} = msg

    case event do
      @new_msg_event ->
        socket =
          assign(socket,
            all_messages:
              socket.assigns.all_messages ++
                [data]
          )

        {:noreply, push_event(socket, "auto-scroll", %{})}

      @join_room_event ->
        {:noreply,
         assign(socket,
           all_messages:
             socket.assigns.all_messages ++
               [data]
         )}

      @user_typing_event ->
        {:noreply,
         assign(socket,
           users_typing:
             socket.assigns.users_typing ++
               [data.user]
         )}

      @user_stop_typing_event ->
        {:noreply,
         assign(socket,
           users_typing:
             socket.assigns.users_typing --
               [data.user]
         )}
    end
  end

  def handle_typing_event(room, users_typing, user, msg) do
    if Enum.member?(users_typing, user) do
      if msg === "" do
        ChatWeb.Endpoint.broadcast!(
          "room:" <> room,
          @user_stop_typing_event,
          %{
            data: %{
              user: user
            }
          }
        )
      end
    else
      if msg !== "" do
        ChatWeb.Endpoint.broadcast!("room:" <> room, @user_typing_event, %{
          data: %{
            user: user
          }
        })
      end
    end
  end

  def user_typing_status(users_typing, username) do
    other_users = Enum.filter(users_typing, fn user -> user !== username end)

    case length(other_users) do
      0 ->
        ""

      1 ->
        Enum.join(other_users, ", ") <> " is typing..."

      _ ->
        Enum.join(other_users, ", ") <> " are typing..."
    end
  end

  def datetime_format(datetime) do
    minute =
      if String.length(Integer.to_string(datetime.minute)) === 1 do
        "0#{datetime.minute}"
      else
        datetime.minute
      end

    "#{datetime.day}-#{datetime.month}-#{datetime.year} #{datetime.hour}:#{minute}"
  end
end
