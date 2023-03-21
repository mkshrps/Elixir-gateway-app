defmodule Sensorhub.Comms do
@moduledoc """
Monitor Lora comms and distribute to receiving servers (processes)
Sondehub
MQTT
Display

"""
  use GenServer
  require Logger
  @server_name SensorHubComms

  def start_link(config \\ []) do
    GenServer.start_link(__MODULE__,config,name: @server_name)
  end

  def init([]) do
    Lora.begin(434.450E6)
    {:ok, %{ payload: []}}
  end

  def handle_cast({:process_payload,payload_data}, state) do
    lora_payload(payload_data)
   {:noreply, Map.put(state,:payload,payload_data)}
  end

  def lora_payload(%{status: status} = payload_data) when status == :ok do
    Sondehub.Telemetry.upload_telem_payload(payload_data)
    Logger.debug("Received payload sending to Sondehub...")
  end

  def lora_payload(_payload_data) do

    Logger.debug("crc Error in lora message")
  end
  # comms API
  def process_payload(payload_data) do
    GenServer.cast(@server_name,{:process_payload, payload_data})
  end

end
