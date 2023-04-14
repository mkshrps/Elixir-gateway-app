defmodule RpiButtons do
  use GenServer
  require Logger

  @button1_default 5
  @button2_default 6
  @button3_default 12

  alias Circuits.GPIO

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
    {:ok, %{gpio1: gpio1, gpio2: gpio2, gpio3: gpio3}}
  end

  def handle_info({:circuits_gpio, @button1_default, _timestamp, _value}, state) do
    Logger.info("Button 1 pressed")
    Logger.info(state)
    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button2_default, _timestamp, _value}, state) do
    Logger.info("Button 2 pressed")
    {:noreply, state}
  end
  # vintage net wizard interrupt
  def handle_info({:circuits_gpio, @button3_default, _timestamp, 1},state) do
    Logger.info("Button 3 pressed")
    {:noreply, state,5000}
  end

# Button released. The GenServer timer is implicitly cancelled by receiving this message.
  def handle_info({:circuits_gpio, @button3_default, _timestamp, 0},state) do
    Logger.info("Button 3 released")
    {:noreply, state}
  end

  def handle_info(:timeout, state) do
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
