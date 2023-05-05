  defmodule SensorHub.DispPage do

    def display_page(page_id,payload,pid) do
      page_list = SensorHub.MqttMsg.parse_display_msg(payload)
      page_items = build_page(page_id,page_list)
      prep_items(page_items.items)
      |> print_page(pid)
    end

    def build_page(1,page_list) do
      page = %{page: 1, title: "Title page", items: [], no_title: false}
      item1 = [
        row: 0,
        col: 0,
        name: "Lon",
        value: String.slice(page_list[:lon],0,6),
        opts: [display_name: false, write: false]
      ]

      item2 = [
        row: 1,
        col: 0,
        name: "Lat",
        #value: page_list[:lat],
        value: String.slice(page_list[:lat],0,6),
        opts: [display_name: false, write: false]
      ]

      item3 = [
        row: 2,
        col: 0,
        name: "Alt",
        value: page_list[:alt],
        opts: [display_name: false, write: false]
      ]
      item4 = [
            row: 0,
            col: 13,
            name: "SNR",
            value: page_list[:snr],
            opts: [display_name: false, write: false]
          ]

      item5 = [
        row: 1,
        col: 13,
        name: "Rss",
        value: page_list[:rssi],
        opts: [display_name: false, write: false]
      ]

      item6 = [
        row: 3,
        col: 0,
        name: "frq",
        value: String.slice(page_list[:frequency],0,6),
        opts: [display_name: false, write: false]
      ]

      item7 = [
        row: 3,
        col: 12,
        name: "ID-",
        value: page_list[:frame],
        opts: [display_name: false, write: false]
      ]
      page_items = [item1, item2, item3, item4, item5, item6, item7]
      # add the items to a page
      Map.put(page, :items, page_items)
      # DispPage.prep_item(page1.items)

    end

    def prep_items(items) do
      Enum.map(items,fn item -> [row: item[:row], col: item[:col], text: item[:name] <> " " <> item[:value]] end)
    end

    def print_page(page_to_print,pid) do
      LcdDisplay.execute(pid,:clear)
      Enum.each(page_to_print, fn item ->
          LcdDisplay.execute(pid,{:set_cursor,item[:row],item[:col]});
          LcdDisplay.execute(pid, {:print, item[:text]})
        end )
    end

    def trim(s) do
      String.slice(s,0,6)
    end








end
