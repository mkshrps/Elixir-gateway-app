defmodule SensorHub.RpiButtons do
  use GenServer
  require Logger

  @button1_default 5
  @button2_default 6
  @button3_default 12

  alias Circuits.GPIO
  alias SensorHub.Comms

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, gpio1} = GPIO.open(@button1_default,:input,pull_mode: :pullup)
    {:ok, gpio2} = GPIO.open(@button2_default,:input,pull_mode: :pullup)
    {:ok, gpio3} = GPIO.open(@button3_default,:input,pull_mode: :pullup)
    GPIO.set_interrupts(gpio1, :rising)
    GPIO.set_interrupts(gpio2, :rising)
    GPIO.set_interrupts(gpio3, :both)
    {:ok, %{gpio1: gpio1, gpio2: gpio2, gpio3: gpio3,timestamp: 0,page: 1}}
  end

  def handle_info({:circuits_gpio, @button1_default, _timestamp, 0}, state) do
    Logger.info("Button 1 pressed")
    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button1_default, _timestamp, 1}, state) do
    Logger.info("Button 1 released")
    Comms.set_page(:page_up)
    {:noreply, state}
  end

   def handle_info({:circuits_gpio, @button2_default, _timestamp, 0}, state) do
    Logger.info("Button 2 pressed")
    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button2_default, _timestamp, 1}, state) do
    Logger.info("Button 2 released")
    Comms.set_page(:page_down)
    {:noreply, state}
  end

  # vintage net wizard interrupt
  def handle_info({:circuits_gpio, @button3_default, timestamp, 0},state) do
    Logger.info("Button 3 pressed")
    Map.put(state,:timestamp,timestamp)
    {:noreply, state,5000}
  end

# Button released. The GenServer timer is implicitly cancelled by receiving this message.
  def handle_info({:circuits_gpio, @button3_default, timestamp, 1},state) do
    Logger.info("Button 3 released")
    timer =   timestamp - state.timestamp
    Logger.info("Timer: #{timer}")
    {:noreply, Map.put(state,:timestamp,timestamp)}
  end

  def handle_info(:timeout, state) do
    Logger.info("vintagenet wizard started")
    :ok = VintageNetWizard.run_wizard(device_info: get_device_info())
    {:noreply, state}
  end

  defp get_device_info() do
    kv =
      Nerves.Runtime.KV.get_all_active()
      |> kv_to_map

    mac_addr = VintageNet.get(["interface", "wlan0", "mac_address"])

    [
      {"WiFi Address", mac_addr},
      {"Serial number", serial_number()},
      {"Firmware", kv["nerves_fw_product"]},
      {"Firmware version", kv["nerves_fw_version"]},
      {"Firmware UUID", kv["nerves_fw_uuid"]}
    ]
  end

  defp kv_to_map(key_values) do
    for kv <- key_values, into: %{}, do: kv
  end

  defp serial_number() do
    with boardid_path when not is_nil(boardid_path) <- System.find_executable("boardid"),
         {id, 0} <- System.cmd(boardid_path, []) do
      String.trim(id)
    else
      _other -> "Unknown"
    end
  end

end
