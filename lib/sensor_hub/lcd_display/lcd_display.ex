defmodule SensorHub.LcdDisplay do
    @doc """
          {:ok,
      %{
        backlight: true,
        cols: 16,
        display_control: 12,
        driver_module: LcdDisplay.HD44780.PCF8574,
        entry_mode: 6,
        i2c_address: 39,
        i2c_ref: #Reference<0.1369082044.268566536.117184>,
        rows: 2
      }}

       :clear), do: {:ok, clear(display)}
   :home), do: {:ok, home(display)}
   {:print, text}), do: {:ok, print(display, text)}
   {:set_cursor, row, col}), do: {:ok, set_cursor(display, row, col)}
   {:cursor, on_off_bool}), do: {:ok, set_display_control_flag(display, @cursor_on, on_off_bool)}
   {:blink, on_off_bool}), do: {:ok, set_display_control_flag(display, @blink_on, on_off_bool)}
   {:display, on_off_bool}), do: {:ok, set_display_control_flag(display, @display_on, on_off_bool)}
   {:autoscroll, on_off_bool}), do: {:ok, set_entry_mode_flag(display, @autoscroll, on_off_bool)}
   {:text_direction, :right_to_left}), do: {:ok, set_entry_mode_flag(display, @entry_left, false)}
   {:text_direction, :left_to_right}), do: {:ok, set_entry_mode_flag(display, @entry_left, true)}
   {:scroll, cols}), do: {:ok, scroll(display, cols)}
   {:right, cols}), do: {:ok, right(display, cols)}
   {:left, cols}), do: {:ok, left(display, cols)}
   {:backlight, on_off_bool}), do: {:ok, set_backlight(display, on_off_bool)}

   config = %{
    i2c_bus: "i2c-1",          # I2C bus name
    i2c_address: 0x27,         # 7-bit address
    rows: 2,                   # the number of display rows
    cols: 16,                  # the number of display columns
    font_size: "5x8"           # "5x10" or "5x8"
  }
  # Start the LCD driver and get the initial display state.
  {:ok, display} = LcdDisplay.HD44780.PCF8574.start(config)

  """

  def start_lcd_display() do

      driver_config = %{
        driver_module: LcdDisplay.HD44780.PCF8574,
        i2c_bus: "i2c-1",          # I2C bus name
        i2c_address: 0x27,         # 7-bit address
        rows: 4,                   # the number of display rows
        cols: 20,                  # the number of display columns
        font_size: "5x8"           # "5x10" or "5x8"
      }
      {:ok, pid} = LcdDisplay.start_link(driver_config)

    end

  end
