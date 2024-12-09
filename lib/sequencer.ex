defmodule Sequencer do
  @moduledoc """
  Documentation for `sequencer`.
  """
  @hi 42
  @bass_drum 36
  @snare 38

  @deck1 "97"
  @led_on "7F"
  @led_off "00"

  @pad1 "00"
  @pad2 "01"
  @pad3 "02"
  @pad4 "03"
  @pad5 "04"
  @pad6 "05"
  @pad7 "06"
  @pad8 "07"

  def pad_list, do: [@pad1, @pad2, @pad3, @pad4, @pad5, @pad6, @pad7, @pad8]
  def pad(no), do: pad_list() |> Enum.at(no)

  # メイン処理
  def start() do
    state = Enum.map(1..8, fn _ -> false end)
    Agent.start_link(fn -> state end, name: __MODULE__)

    {_, input} = PortMidi.open(:input, "DDJ-FLX4 MIDI 1")
    {_, output} = PortMidi.open(:output, "DDJ-FLX4 MIDI 1")

    pad_list()
    |> Enum.each(&pad_led(output, @deck1, &1, @led_off))

    {:ok, synth} = MIDISynth.start_link([])
    PortMidi.listen(input, self())
    Task.async(fn -> track(synth) end)
    midi_in(input, output)

    PortMidi.close(:input, input)
    PortMidi.close(:output, output)
  end

  # 入力処理
  def midi_in(input, output) do
    receive do
      # {^input, [{{144, 11, 0}, _}]} ->
      #   IO.inspect("end")

      {^input, [{{_, no, 127}, _}]} ->
        flg = get_button_state(no)
        set_button_state(no, !flg)

        get_state()
        |> IO.inspect()

        pad_led(output, @deck1, pad(no), led_sw(!flg))

        midi_in(input, output)

      _ ->
        midi_in(input, output)
    end
  end

  # リズムパターンで鳴らす
  def track(synth) do
    get_state()
    |> Enum.each(fn x ->
      drum(synth, 1, x)
      Process.sleep(50)
    end)

    track(synth)
  end

  # ここから音を鳴らす制御
  def drum(synth, 0, true), do: play(synth, @bass_drum)
  def drum(synth, 1, true), do: play(synth, @snare)
  def drum(synth, 2, true), do: play(synth, @hi)
  def drum(_, _, _), do: nil

  def play(synth, note), do: MIDISynth.Keyboard.play(synth, note, 50, 127, 9)
  # ここまで音を鳴らす制御

  # 　ここからPadボタンのON/OFF制御
  def get_button_state(index) do
    get_state()
    |> Enum.at(index)
  end

  def set_button_state(index, flg) do
    get_state()
    |> List.replace_at(index, flg)
    |> set_state()
  end

  def get_state, do: Agent.get(__MODULE__, & &1)
  def set_state(state), do: Agent.update(__MODULE__, fn _ -> state end)

  def pad_led(output, deck, pad, led_sw) do
    [deck, pad, led_sw]
    |> send_midi(output)
  end

  def hex_to_dec(hex), do: String.to_integer(hex, 16)

  def send_midi(v, output) do
    Enum.map(v, fn x -> hex_to_dec(x) end)
    |> List.to_tuple()
    |> then(&PortMidi.write(output, &1))
  end

  def led_sw(true), do: @led_on
  def led_sw(_), do: @led_off
  # ここまでPadボタンのON/OFF制御
end
