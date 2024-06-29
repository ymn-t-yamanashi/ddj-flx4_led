defmodule Hoge do
  @moduledoc """
  Documentation for `Hoge`.
  """


  def hello() do
    PortMidi.devices
    |> IO.inspect()

    {_, output} = PortMidi.open(:output, "DDJ-FLX4 MIDI 1")
    |> IO.inspect()
    Enum.each(1..100, fn _ -> led(output) end)
    PortMidi.close(:output, output)

    :world
  end

  def led(output) do
    ["B0","02", "7f"]
    |> send_midi(output)
    Process.sleep(200)
    ["B0","02", "00"]
    |> send_midi(output)
    Process.sleep(200)
    ["B1","02", "7f"]
    |> send_midi(output)
    Process.sleep(200)
    ["B1","02", "00"]
    |> send_midi(output)
    Process.sleep(200)
  end

  def send_midi(v, output) do
    data = Enum.map(v, fn x ->  h(x)  end)
    |> List.to_tuple()
    |> IO.inspect()
    PortMidi.write(output, data)
  end

  def h(v) do
    {a, _} = Integer.parse(v, 16)
    a
  end
end
