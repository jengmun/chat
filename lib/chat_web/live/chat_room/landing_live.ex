defmodule ChatWeb.LandingLive do
  require Logger
  use ChatWeb, :live_view
  require ChatWeb.Constants

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        room: ""
      )

    {
      :ok,
      socket
    }
  end
end
