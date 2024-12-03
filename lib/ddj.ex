defmodule Ddj do
  @moduledoc """
  Documentation for `Ddj`.
  """

  def led_on, do: "7F"
  def led_off, do: "00"

  def pad1, do: "00"
  def pad2, do: "01"
  def pad3, do: "02"
  def pad4, do: "03"
  def pad5, do: "04"
  def pad6, do: "05"
  def pad7, do: "06"
  def pad8, do: "07"

  def deck1, do: "97"
  def deck2, do: "99"

  def pad_list, do: [pad1(), pad2(), pad3(), pad4(), pad5(), pad6(), pad7(), pad8()]

  def open do
    {_, output} = PortMidi.open(:output, "DDJ-FLX4 MIDI 1")
    output
  end

  def close(output) do
    PortMidi.close(:output, output)
  end

  def send_midi(v, output) do
    Enum.map(v, fn x -> hex_to_dec(x) end)
    |> List.to_tuple()
    |> then(&PortMidi.write(output, &1))
  end

  def hex_to_dec(hex), do: String.to_integer(hex, 16)

  def pad_led(output, deck, pad, led_sw) do
    [deck, pad, led_sw]
    |> send_midi(output)
  end
end
