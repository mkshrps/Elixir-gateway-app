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
    GPIO.set_interrupts(gpio3, :rising)
    {:ok, %{gpio1: gpio1, gpio2: gpio2, gpio3: gpio3}}
  end

  def handle_info({:circuits_gpio, @button1_default, _timestamp, value}, state) do
    Logger.info("Button 1 pressed")
    Logger.info(state)
    {:noreply, state}
  end
  def handle_info({:circuits_gpio, @button2_default, _timestamp, value}, state) do
    Logger.info("Button 2 pressed")
    {:noreply, state}
  end
  def handle_info({:circuits_gpio, @button3_default, _timestamp, value}, state) do
    Logger.info("Button 3 pressed")
    {:noreply, state}
  end
end
