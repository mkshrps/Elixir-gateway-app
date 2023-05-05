defmodule SensorHub.Comms do
@moduledoc """
Monitor Lora comms and distribute to receiving servers (processes)
Sondehub
MQTT
Display

"""
  alias SensorHub.DispPage

  @default_lora_frq 434.450E6
  @default_ukhas_mode 1
  @max_pages  2
  @lcd_fitted false

  use GenServer
  require Logger
  @server_name SensorHubComms

  def start_link(config \\ []) do
    GenServer.start_link(__MODULE__,config,name: @server_name)
  end

  def init([]) do
    # preset lora payload data with initialisation string
    payload = %{status: :ok, payload: lora_msg(), snr: "0.0", rssi: "0", frq: "-----", crc_error: false}
    #payload = %Lora{} // initialise payload data with lora struct
    lora_settings = %{set_frq: @default_lora_frq, ukhas_mode: @default_ukhas_mode,auto_tune: true}
    crc_count = 0;
    # only start the display update if configured
    lcd_pid = if @lcd_fitted do
      {:ok,lcd_pid} = SensorHub.LcdDisplay.start_lcd_display()
       Process.send_after(self(),:display_update,2000)
       # set up the state for comm
       lcd_pid
    end

   state = %{
      lora: %{
      settings: lora_settings,
      payload: payload,
      crc_count: crc_count
      },
      display: %{ page: 1, lcd_pid: lcd_pid}
    }
   #{:ok, %{ payload: payload, page: 1,lcd_pid: lcd_pid,crc_count: 0}}
    {:ok, state}
  end

  # lora sends this data when received
  def handle_cast({:process_payload,payload_data}, state) do
    # send the payload to sondehub and mqtt
    state = lora_payload(payload_data,state)
    # save the payload
    {:noreply,state}
  end

  def handle_cast({:process_setting,setting_data}, state) do
    Logger.debug("Comms handler setpoint change request #{setting_data}")
    {response, state} = update_setpoint(setting_data,state)
    Logger.info("#{inspect(response)}")
    {:noreply, state}
  end

  def handle_cast({:page_change,command}, state) do
    state = page(command,state)
    {:noreply, state}
  end




  def handle_info(:display_update, state) do
    DispPage.display_page(1,state.lora[:payload],state.display.lcd_pid)
    #Logger.info("display_page #{inspect(state.lora.payload)}")
    Process.send_after(self(),:display_update,3000)
    {:noreply,state}
  end

  def lora_payload(%{status: status} = payload_data,state) when status == :ok do
    Sondehub.Telemetry.upload_telem_payload(payload_data)
    Logger.debug("Received payload sending to Sondehub...")
    SensorHub.MqttMsg.upload_telemetry(payload_data)
    put_in(state.lora.payload,payload_data)
#    Map.put(state,:payload,payload_data)
  end

  def lora_payload(_payload_data,state) do

    Logger.debug("crc Error in lora message")
    # don't update payload if crc error
    put_in(state.lora.crc_count,state.lora.crc_count + 1)
#    Map.put(state,:crc_count,state[:crc_count] + 1)

  end

  def update_setpoint(key_value_string,state) do
    [k,v] = String.split(key_value_string,",")
    key = String.to_atom(k)
    set_new_value(key,v,state)
  end

  def set_new_value(:lora_frq,value,state) do
    {value,_} = Float.parse(value)
    #Lora.set_frq(value)
    state = put_in(state.lora.settings.set_frq,value)
    {:ok,state}
  end

  def set_new_value(:set_auto_tune,value,state)  do
    #Lora.set_auto_tune(String.to_atom(value))
    state = put_in(state.lora.settings.auto_tune,value)
    {:ok,state}
  end

  def set_new_value(_,_value,state) do
    {:error,state}
  end

  #  dummy lora message for initialising state
  @lora_msg "$$FLOPPY445,000,00:00:00,0.000000,0.000000,0,0,0,0,18,0.00, 0.00,0.00,3408,0,3,0*A2BC"

  def lora_msg(), do: @lora_msg

  def page(:page_up,state) do
    page = if state.display.page + 1 > @max_pages do 0 else state.display.page +1 end
    Logger.info("new page selected #{page}")
    put_in(state.display.page, page)

  end

  def page(:page_down,state) do
    page = if state.display.page - 1 < 0  do 0 else state.display.page - 1 end
    Logger.info("new page selected #{page}")
    put_in(state.display.page, page)

  end


    # comms API
  def process_payload(payload_data) do
    GenServer.cast(@server_name,{:process_payload, payload_data})
  end

  # command == :page_up | :page_down
  def set_page(command) do
    GenServer.cast(@server_name,{:page_change,command})
    #Logger.info("setpage command invalid #{command}")
  end

end
