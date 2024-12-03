defmodule Pad do
  @moduledoc """
  Documentation for `pad`.
  """

  @led_on "7F"
  @led_of "00"

  @pad1 "00"
  @pad2 "01"
  @pad3 "02"
  @pad4 "03"
  @pad5 "04"
  @pad6 "05"
  @pad7 "06"
  @pad8 "07"

  @deck1 "97"
  @deck2 "99"

  @pad_list [@pad1, @pad2, @pad3, @pad4, @pad5, @pad6, @pad7, @pad8]

  def start() do
    {_, output} = PortMidi.open(:output, "DDJ-FLX4 MIDI 1")

    Enum.each(0..7, fn pad -> pad_led(output, pad) end)
    PortMidi.close(:output, output)
  end

  def pad_led(output, pad) do
    pad_hex = Enum.at(@pad_list, pad)
    pad_led(output, @deck1, pad_hex)
    pad_led(output, @deck2, pad_hex)
  end

  def pad_led(output, deck, pad) do
    [deck, pad, @led_on]
    |> send_midi(output)

    Process.sleep(500)

    [deck, pad, @led_of]
    |> send_midi(output)

    Process.sleep(100)
  end

  def send_midi(v, output) do
    Enum.map(v, fn x -> hex_to_dec(x) end)
    |> List.to_tuple()
    |> then(&PortMidi.write(output, &1))
  end

  def hex_to_dec(hex), do: String.to_integer(hex, 16)
end
