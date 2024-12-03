defmodule Pad do
  @moduledoc """
  Documentation for `pad`.
  """

  def start() do
    {_, output} = PortMidi.open(:output, "DDJ-FLX4 MIDI 1")

    Enum.each(1..10, fn _ -> led(output) end)
    PortMidi.close(:output, output)

    :world
  end

  def led(output) do
    ["B0", "02", "7f"]
    |> send_midi(output)

    Process.sleep(100)

    ["B0", "02", "00"]
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
