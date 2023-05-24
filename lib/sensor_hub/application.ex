defmodule SensorHub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options

    Wifi_wizard.start_wizard()
    import Supervisor.Spec, warn: false

    opts = [strategy: :one_for_one, name: SensorHub.Supervisor]

    children =
      [
        # Children for all targets
        # {SensorHub.Worker, arg},
        #{SensorHub.RpiButtons}
      ] ++ children(target())

    Supervisor.start_link(children, opts)

  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: SensorHub.Worker.start_link(arg)
      # {SensorHub.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: SensorHub.Worker.start_link(arg)
      # {SensorHub.Worker, arg},
      #SensorHub.Display
      Lora,
      SensorHub.Comms,
      Sondehub.Telemetry,
      {Sondehub.Listener, [
      software_name: "Elixir Gateway" ,
      software_version: "1.0.1",
      uploader_callsign: "CranlyBase",
      uploader_position: [53.3012,-2.520200,50],
      uploader_antenna: "Diamond X500",
      uploader_contact_email: "",
      mobile: false
      ] },
      # start the mqtt supervisor app which fires up the totoise app
      {MqttGateway.Connection,[clientid: "mqtt_gateway"]},
      SensorHub.RpiButtons
    ]
  end

  def target() do
    Application.get_env(:sensor_hub, :target)
  end
end
