defmodule Hoge2 do
  @moduledoc """
  Documentation for `Hoge`.
  """

  def hello() do
    {_, input} = PortMidi.open(:input, "DDJ-FLX4 MIDI 1")
    PortMidi.listen(input, self())
    midi_in(input)

    PortMidi.close(:output, input)
  end

  def midi_in(input) do
    receive do
      {^input, [{{144, 11, 0}, _}]} ->
        IO.inspect("end")

      {^input, [{event, _}]} ->
        IO.inspect(event)
        midi_in(input)

      a ->
        IO.inspect(a)
        midi_in(input)
    end
  end
end
