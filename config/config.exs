# This file is responsible for configuring your application and its
# dependencies.
#
# This configuration file is loaded before any dependency and is restricted to
# this project.
import Config

# Enable the Nerves integration with Mix
Application.start(:nerves_bootstrap)

config :sensor_hub, target: Mix.target()
config :logger, backends: [RingLogger]
config :logger, RingLogger,
  application_levels: %{my_app: :error},
  colors: [debug: :yellow],
  level: :debug
# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :sensor_hub, SensorHub.Display,
  device: "i2c-1",  # Device (i.e.: `spidev0.0`, `i2c-1`, ...)
  driver: :ssd1306,     # Driver. (Only SSD1306 for now)
  type: :i2c,           # Connection type: `:spi` or `:i2c`
  #width: 128,           # Display Width
  #height: 64,           # Display Height
  #rst_pin: 25,          # Reset GPIO pin (SPI only)
  #dc_pin: 24,            # DC GPIO pin (SPI only)
  address: 0x3C         # DC GPIO pin (I2C only)

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1675360416"
#config :shoehorn,
#  init: [:nerves_runtime, :nerves_pack],
#  app: Mix.Project.config()[:app]
if Mix.target() == :host do
  import_config "host.exs"
else
  import_config "target.exs"
end
