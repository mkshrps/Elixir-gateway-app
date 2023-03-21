defmodule Wifi_wizard do

    def start_wizard() do
      if should_start_wizard?() do
      VintageNetWizard.run_wizard
    end

  end

  def should_start_wizard?() do
    #true
    false
  end
end
