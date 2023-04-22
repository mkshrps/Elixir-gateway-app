defmodule SensorHub.Comms do
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
    # peset display data with dummy list
    lora_payload = SensorHub.MqttMsg.lora_msg()
    payload = %{payload: lora_payload, snr: "1.1", rssi: "-90", frq: "434.450"}

    {:ok,lcd_pid} = SensorHub.LcdDisplay.start_lcd_display()

    Process.send_after(self(),:display_update,2000)
#    SensorHub.Display.start_link()
#    SensorHub.Display.test_text("helvb12.bdf")
    {:ok, %{ payload: payload,page: 1,lcd_pid: lcd_pid}}
  end

  def handle_cast({:process_payload,payload_data}, state) do
    # send the payload to sondehub and mqtt
    lora_payload(payload_data)
    # save the payload
    {:noreply, Map.put(state,:payload,payload_data)}
  end

  def handle_cast({:process_setting,setting_data}, state) do
    Logger.debug("Comms handler setpoint change request #{setting_data}")
    update_setpoint(setting_data)
   {:noreply, state}
  end

  def handle_info(:display_update, state) do
    DispPage.display_page(1,state[:payload],state.lcd_pid)
    #Logger.info("display_page #{state.payload}")
    Process.send_after(self(),:display_update,3000)
    {:noreply,state}
  end

  def lora_payload(%{status: status} = payload_data) when status == :ok do
    Sondehub.Telemetry.upload_telem_payload(payload_data)
    Logger.debug("Received payload sending to Sondehub...")
    SensorHub.MqttMsg.upload_telemetry(payload_data)
    # convert lora payload to keyword list for the display_data

  end

  def lora_payload(_payload_data) do

    Logger.debug("crc Error in lora message")
  end

    # comms API
  def process_payload(payload_data) do
    GenServer.cast(@server_name,{:process_payload, payload_data})
  end

  def update_setpoint(key_value_string) do
    [k,v] = String.split(key_value_string,",")
    key = String.to_atom(k)
    set_new_value(key,v)
  end

  def set_new_value(:lora_frq,value) do
    {value,_} = Float.parse(value)
    Lora.set_frq(value)
    {:ok,value}
  end

  def set_new_value(:set_auto_tune,value)  do

    Lora.set_auto_tune(String.to_atom(value))

    {:ok,value}
  end

  def set_new_value(_,value) do
    {:setpoint_not_found,value}
  end

end
