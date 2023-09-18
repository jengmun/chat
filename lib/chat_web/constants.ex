defmodule ChatWeb.Constants do
  @new_message_event "New Message"

  defmacro new_message_event do
    @new_message_event
  end

  defmodule Channels do
    def lobby do
      "room:lobby"
    end
  end
end
