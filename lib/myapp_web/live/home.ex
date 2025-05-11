defmodule MyappWeb.Home do
  use MyappWeb, :live_view

  alias Myapp.Presence

  @presence_topic "home_presence"

  def mount(_params, _session, socket) do
    answers = [
      "YES!",
      "No :/",
      "Maybe?",
      "You deserve it",
      "Treat yourself!",
      "Chipotleeeee",
      "Late night Taco Bell run...?",
      "Absoloutely",
      "Ehhh, how about we save some money",
      "It's good for the economy!",
      "Don't think so",
      "Nice try",
      "Only if we get a sweet treat after",
      "Thought you'd never ask :')"
    ]

    initial_present =
      if connected?(socket) do
        Presence.track(self(), @presence_topic, socket.id, %{})
        MyappWeb.Endpoint.subscribe(@presence_topic)

        Presence.list(@presence_topic)
        |> map_size
      else
        0
      end

    {:ok,
     assign(socket,
       answers: answers,
       answer: Enum.random(answers),
       present: initial_present
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white">
      <div class="px-6 py-24 sm:px-6 sm:py-32 lg:px-8">
        <div class="mx-auto max-w-2xl text-center">
          <h1 class="text-balance text-3xl font-semibold tracking-tight text-gray-600">
            Should I Eat Out Today?
          </h1>
          <div class="mx-auto mt-6 max-w-xl text-8xl text-pretty text-gray-900 font-black">
            {@answer}
          </div>
          <div class="mt-10 flex items-center justify-center gap-x-6">
            <button phx-click="answer-question">
              Hit <span class="border-2 p-1 m-1 rounded-lg border-solid">Space</span> or Click
            </button>
          </div>
          <div phx-window-keydown="key_down"></div>
        </div>
      </div>
    </div>

    <div class="mt-10 text-center">
      <.live_component module={PresenceComponent} id="home_presence" present={@present - 1} /> other
      <%= if @present - 1 == 1 do %>
        person
      <% else %>
        people
      <% end %>
      trying to decide.
    </div>
    """
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{present: present}} = socket
      ) do
    {_, joins} = Map.pop(joins, socket.id, %{})
    new_present = present + map_size(joins) - map_size(leaves)
    {:noreply, assign(socket, :present, new_present)}
  end

  # Handles the button clicks
  def handle_event("answer-question", _, socket) do
    new_answer = Enum.random(socket.assigns.answers)
    {:noreply, assign(socket, answer: new_answer)}
  end

  # Handles the key down events
  def handle_event("key_down", %{"key" => " "}, socket) do
    new_answer = Enum.random(socket.assigns.answers)
    {:noreply, assign(socket, answer: new_answer)}
  end

  def handle_event("key_down", _, socket) do
    {:noreply, socket}
  end
end
