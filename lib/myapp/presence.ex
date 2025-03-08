defmodule Myapp.Presence do
  use Phoenix.Presence,
    otp_app: :myapp,
    pubsub_server: Myapp.PubSub
end
