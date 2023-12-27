defmodule Chats.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages) do
      add :sender, :string
      add :room, :string
      add :datetime, :integer
      add :message, :string
    end
  end
end
