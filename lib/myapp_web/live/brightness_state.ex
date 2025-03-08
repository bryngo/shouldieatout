defmodule MyappWeb.Brightness do
  use GenServer
  alias Phoenix.PubSub

  @name :brightness_server
  @start_value 10

  # External API (runs in client process)

  def topic do
    "brightness"
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, @start_value, name: @name)
  end

  def incr() do
    GenServer.call(@name, :incr)
  end

  def decr() do
    GenServer.call(@name, :decr)
  end

  def current() do
    GenServer.call(@name, :current)
  end

  def init(start_brightness) do
    {:ok, start_brightness}
  end

  # Implementation (Runs in GenServer process)
  def handle_call(:current, _from, brightness) do
    {:reply, brightness, brightness}
  end

  def handle_call(:incr, _from, brightness) do
    make_change(brightness, +1)
  end

  def handle_call(:decr, _from, brightness) do
    make_change(brightness, -1)
  end

  defp make_change(brightness, change) do
    new_brightness = brightness + change
    PubSub.broadcast(Myapp.PubSub, topic(), {:brightness, new_brightness})
    {:reply, new_brightness, new_brightness}
  end
end
