defmodule ChatWeb.ChatRoomLive do
  require Logger
  use ChatWeb, :live_view
  require ChatWeb.Constants

  @new_msg_event ChatWeb.Constants.ChannelEvents.new_message_event()
  @join_room_event ChatWeb.Constants.ChannelEvents.join_room_event()
  @user_typing_event ChatWeb.Constants.ChannelEvents.user_typing_event()
  @user_stop_typing_event ChatWeb.Constants.ChannelEvents.user_stop_typing_event()

  def mount(_params, session, socket) do
    %{"username" => username, "room" => room} = session

    socket =
      assign(socket,
        all_messages: [],
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
              recipient: socket.assigns.room,
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
          recipient: socket.assigns.room,
          message: message,
          datetime: datetime
        }
      })

      if Enum.member?(socket.assigns.users_typing, socket.assigns.username) do
        ChatWeb.Endpoint.broadcast!("room:" <> socket.assigns.room, @user_stop_typing_event, %{
          data: %{
            user: socket.assigns.username
          }
        })
      end

      {:noreply, assign(socket, input_value: "")}
    end
  end

  def handle_event("change", %{"message" => message}, socket) do
    if !Enum.member?(socket.assigns.users_typing, socket.assigns.username) and message !== "" do
      ChatWeb.Endpoint.broadcast!("room:" <> socket.assigns.room, @user_typing_event, %{
        data: %{
          user: socket.assigns.username
        }
      })
    else
      if Enum.member?(socket.assigns.users_typing, socket.assigns.username) and message === "" do
        ChatWeb.Endpoint.broadcast!("room:" <> socket.assigns.room, @user_stop_typing_event, %{
          data: %{
            user: socket.assigns.username
          }
        })
      end
    end

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
end
