defmodule ChatWeb.SidebarLive do
  require Logger
  use ChatWeb, :live_view
  require ChatWeb.Constants

  @lobby ChatWeb.Constants.Channels.lobby()

  def mount(_params, _session, socket) do
    ChatWeb.Endpoint.subscribe(@lobby)

    socket = assign(socket, :msg, 0)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div>
      <h1>Message 2: <%= @msg %></h1>
    </div>
    """
  end

  def handle_info(msg, socket) do
    %{body: body} = msg.payload
    IO.inspect(body, label: "Handling info")

    {:noreply, assign(socket, :msg, body)}
  end
end
