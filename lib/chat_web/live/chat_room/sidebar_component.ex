defmodule ChatWeb.SidebarComponent do
  require Logger
  use ChatWeb, :live_component
  require ChatWeb.Constants

  def mount(_params, _session, socket) do
    {:ok, assign(socket, username: "")}
  end

  def render(assigns) do
    IO.inspect(assigns, label: "ASSSIGNGNGNGNS")

    ~H"""
    <div id="getUsername" phx-hook="getUsername">
      Sidebar <%= @username %>
    </div>
    """
  end
end
