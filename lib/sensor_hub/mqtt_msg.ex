defmodule SensorHub.MqttMsg do
  require Logger
  alias MqttGateway.Mqtt

  @payload_fields [
    :call_sign,
    :frame,
    :datetime,
    :lat,
    :lon,
    :alt,
    :gps_speed,
    :gps_heading,
    :gps_sattelites,
    :internal_temp,
    :external_temp,
    :pressure,
    :humidity,
    :battery_voltage,
    :ascent_rate,
    :gps_flight_mode,
    :devices_running
  ]

  def send_telemetry_to_mqtt(telem) do
    #Logger.info(telem)
    # call Mqtt upadte API
    Mqtt.update_payload(telem)
  end

  def upload_telemetry(payload_data) do
    payload_data
    |> parse_msg()
    |> convert_to_json()
    |> send_telemetry_to_mqtt()
  end

  def convert_to_json(body) do
    # then to json
    {:ok,json_content} = JSON.encode(body)
    # wrap in [] for telemetry
    "[#{json_content}]"
  end

  # parse payload to a keyword list defined by @payload_fields but format all fields as strings
  # for displaying in LCD display
  def parse_display_msg(%{:payload => payload,:snr => snr,:rssi => rssi, :frq => frq } = _message_data) do
    payload
    |> lora_msg_to_list()
    |> get_standard_fields()  # just take standard fields out of payload
    |> add_keywords_to_list(@payload_fields)
    |> parse_to_strings(snr,rssi,frq)
  end

  # format as keyword list format certain fields as numeric this is the same as required for sondehub
  # we send the same format to Mqtt
  def parse_msg(%{:payload => payload,:snr => snr,:rssi => rssi, :frq => frq } = _message_data) do
    payload                   # raw loara message from tracker in UKhas format
    |> lora_msg_to_list()
    |> get_standard_fields()  # just take standard fields out of payload
    |> add_keywords_to_list(@payload_fields)
    |> add_device_details(snr,rssi,frq)
    |> parse_to_int(:frame)
    |> parse_to_float(:lon)
    |> parse_to_float(:lat)
    |> parse_to_int(:alt)
  end

  # convert incoming telem message to lis and adds additional prams
  def lora_msg_to_list(io_str) do
    lora_msg_to_string(io_str)
    |> String.trim("$$") |> String.split("*") |> Enum.fetch!(0) |> String.split(",")
 end


  # get all the fields in the message
  # this will change when handling unknown payloads
  def get_standard_fields(fields_list) do
    fields_list
  end

   def lora_msg_to_string(io_str) do
    IO.iodata_to_binary(io_str)
  end

  def lora_msg_id(lora_msg) do
    {id,_rest} = String.split(lora_msg,",")
    |> List.pop_at(1)
    String.to_integer(id)

  end
  # convert all fields to trings for display
  def parse_to_strings(lora_list,snr,rssi,frq) do
    lst = [snr: "#{snr}", rssi: "#{rssi}", frequency: "#{frq}" ]
    lora_list ++ lst
  end



  def add_device_details(lora_list,snr,rssi,frq,[]) do
    lst = [snr: snr, rssi: rssi, frequency: frq ]
    lora_list ++ lst
  end

  # extra details to be addd to head of list (reverse order)
  def add_device_details(lora_list,snr,rssi,frq) do
    lst = [snr: snr, rssi: rssi, frequency: frq]
    lora_list ++ lst
  end

  #def hab_keys_ext do @hab_keys_ext end
  def add_keywords_to_list(hab_msg_list,hab_keys) do
    #create a keyword list
    Enum.zip(hab_keys,hab_msg_list)
  end

  def is_telem?(str_msg) do
    test = fn "$$" -> true
      _ -> false
    end
    test.(String.slice(str_msg,0..1))
  end

  def add_custom_fields(list,_custom) do
    list
  end

  defp parse_to_int(list,key) do
    {_,list } = Keyword.get_and_update(list,key, fn c -> {c, String.to_integer(c)} end)
    list
    end

  defp parse_to_float(list,key) do
     {_,list } = Keyword.get_and_update(list,key, fn c -> {c, String.to_float(c)} end)
     list
  end



end
