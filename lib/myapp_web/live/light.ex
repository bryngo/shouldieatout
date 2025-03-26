defmodule MyappWeb.Light do
  use MyappWeb, :live_view

  alias MyappWeb.Brightness
  alias Phoenix.PubSub
  alias Myapp.Presence

  @topic Brightness.topic()
  @presence_topic "light_presence"

  def mount(_params, _session, socket) do
    initial_present =
      if connected?(socket) do
        PubSub.subscribe(Myapp.PubSub, @topic)

        Presence.track(self(), @presence_topic, socket.id, %{})
        MyappWeb.Endpoint.subscribe(@presence_topic)

        Presence.list(@presence_topic)
        |> map_size
      else
        0
      end

    {:ok, assign(socket, brightness: Brightness.current(), present: initial_present)}
  end

  # render
  def render(assigns) do
    ~H"""
    <h1>Front porch light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%"} class="bg-red-500 block">
          {@brightness}
        </span>
      </div>
      <button phx-click="up">
        Up Brightness
      </button>
      -
      <button phx-click="down">
        Down Brightness
      </button>
    </div>
    <.live_component module={PresenceComponent} id="presence" present={@present} />
    """
  end

  # TO DO https://fly.io/phoenix-files/saving-and-restoring-liveview-state/

  # Broadcast to the rest of the clients
  def handle_info({:brightness, brightness}, socket) do
    {:noreply, assign(socket, brightness: brightness)}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{present: present}} = socket
      ) do
    {_, joins} = Map.pop(joins, socket.id, %{})
    new_present = present + map_size(joins) - map_size(leaves)
    {:noreply, assign(socket, :present, new_present)}
  end

  def handle_event("up", _, socket) do
    {:noreply, assign(socket, brightness: Brightness.incr())}
  end

  def handle_event("down", _, socket) do
    {:noreply, assign(socket, brightness: Brightness.decr())}
  end
end
