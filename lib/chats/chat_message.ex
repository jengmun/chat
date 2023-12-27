defmodule Chats.ChatMessage do
  use Ecto.Schema

  schema "chat_messages" do
    field(:sender, :string)
    field(:room, :string)
    field(:datetime, :integer)
    field(:message, :string)
  end
end
