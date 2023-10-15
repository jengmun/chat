defmodule ChatWeb.LoginLive do
  require Logger
  use ChatWeb, :live_view
  require ChatWeb.Constants

  def mount(_params, _session, socket) do
    socket = assign(socket, form: to_form(%{}))

    {:ok, socket}
  end

  def handle_event("submit", %{"username" => username}, socket) do
    {:noreply,
     push_event(socket, "session-storage", %{method: :setItem, data: %{username: username}})}
  end

  def handle_event("redirect_to_chat", _params, socket) do
    {:noreply, push_navigate(socket, to: "/chat")}
  end
end
