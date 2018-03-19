defmodule <%= @mod %>.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [<%= if @rtc do %>
      Supervisor.child_spec({Task, &set_datetime/0}, id: :set_datetime)<%= if @ntp do %>,
      Supervisor.child_spec({Task, &sync_rtc/0}, id: :sync_rtc)<% end %><% end %>
      # <%= @mod %>.Worker1,
      # {<%= @mod %>.Worker2, arg},
    ]

    opts = [strategy: :one_for_one, name: <%= @mod %>.Supervisor]
    Supervisor.start_link(children, opts)
  end<%= if @rtc do %>

  # Sets the datetime from the DS3231 RTC.
  defp set_datetime do
    with {:ok, datetime} <- RtcDs3231.rtc_datetime(0x68),
         {_, 0} <- System.cmd("date", [NaiveDateTime.to_string(datetime)]),
         do: :ok
  end<%= if @ntp do %>

  # Syncs the RTC with current OS time.
  defp sync_rtc do
    # Sleep 15 seconds to let NTP to sync.
    Process.sleep(15_000)

    datetime = NaiveDateTime.utc_now() |> NaiveDateTime.add(1)
    RtcDs3231.set_rtc_datetime(0x68, datetime)
  end<% end %><% end %>
end
