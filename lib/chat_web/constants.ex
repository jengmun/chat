defmodule ChatWeb.Constants do
  defmodule ChannelEvents do
    def new_message_event do
      "NEW_MESSAGE"
    end

    def join_room_event do
      "JOIN_ROOM"
    end

    def user_typing_event do
      "USER_TYPING"
    end

    def user_stop_typing_event do
      "USER_STOP_TYPING"
    end
  end
end
