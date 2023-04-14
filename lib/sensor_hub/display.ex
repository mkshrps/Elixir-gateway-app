defmodule SensorHub.Display do
  @moduledoc """
  Documentation for `Display`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Display.hello()
      :world

  """
  use OLED.Display, app: :sensor_hub

  require Logger
  alias Circuits.I2C

  def bus_names do
    I2C.bus_names()
  end

  def detect_devices() do
    I2C.detect_devices()
  end

  def draw_test() do
    # Draw something
  rect(0, 0, 127, 63)
  line(0, 0, 127, 63)
  line(0, 63, 127, 0)

  # Display it!
  display()
  end

  def get_font(bdf) do
    path = :code.priv_dir(:sensor_hub)

    {:ok, font} = Chisel.Font.load(Path.join(path,bdf))
    font
  end

  def display_draw_text(font,text) do
    do_pixel = fn x, y, _t ->
      SensorHub.Display.put_pixel(x,y,[state: :on, mode: :normal])
    end

    {_pixels, _, _} = Chisel.Renderer.reduce_draw_text(text,0,0, font, [], do_pixel)
  end

  def display_draw_text(font,text,xpos,ypos) do
    do_pixel = fn x, y, _t ->
      SensorHub.Display.put_pixel(x,y,[state: :on, mode: :normal])
    end

    {_pixels, _, _} = Chisel.Renderer.reduce_draw_text(text,xpos,ypos, font, [], do_pixel)
  end

  def test_text(font_file) do
    SensorHub.Display.clear()
    font = get_font(font_file)
    display_draw_text(font,"Sharptek LoRa")
    display_draw_text(font,"Connected",10,20)
    SensorHub.Display.display()

  end

  def message_count() do

  end
end
