defmodule Synth do
  @moduledoc """
  Documentation for `Synth`.
  """
  @hi 42
  @bass_drum 36
  @snare 38

  def start() do
    {_, input} = PortMidi.open(:input, "DDJ-FLX4 MIDI 1")
    {:ok, synth} = MIDISynth.start_link([])
    PortMidi.listen(input, self())
    midi_in(input, synth)

    PortMidi.close(:output, input)
  end

  def midi_in(input, synth) do
    receive do
      {^input, [{{144, 11, 0}, _}]} ->
        IO.inspect("end")

      {^input, [{{_, no, 127}, _}]} ->
        drum(synth, no)
        IO.inspect(no)

        midi_in(input, synth)

      _ ->
        midi_in(input, synth)
    end
  end

  def drum(synth, 0), do: play(synth, @bass_drum)
  def drum(synth, 1), do: play(synth, @snare)
  def drum(synth, 2), do: play(synth, @hi)
  def drum(_, _), do: nil

  def play(synth, note), do: MIDISynth.Keyboard.play(synth, note, 200, 127, 9)
end
