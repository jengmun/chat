defmodule ChatWeb.ChatLive do
  require Logger
  use ChatWeb, :live_view
  require ChatWeb.Constants

  @new_msg_event ChatWeb.Constants.new_message_event()
  @lobby ChatWeb.Constants.Channels.lobby()

  def mount(_params, _session, socket) do
    socket = assign(socket, :msg, 0)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div>
    <input/>
      <h1>Message: <%= @msg %></h1>
      <button phx-click="increment" >Increment</button>
        </div>
    
    """
  end

  def handle_event("increment", _unsigned_params, socket) do
    new_msg = socket.assigns.msg + 1
    broadcast_message(new_msg)
    {:noreply, assign(socket, :msg, new_msg)}
  end

  defp broadcast_message(new_msg) do
    ChatWeb.Endpoint.broadcast!(@lobby, @new_msg_event, %{body: new_msg})
  end
end
