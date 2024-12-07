defmodule Mogu do
  @moduledoc """
  Documentation for `Mogu`.
  """
  import Ddj

  def start() do
    output = open()
    input = open(:input)
    PortMidi.listen(input, self())

    pad_randoms(output, input)
    |> Enum.count(fn x -> x end)
    |> IO.inspect()

    close(input, :input)
    close(output)
  end

  def pad_randoms(output, input) do
    1..30
    |> Enum.map(fn _ ->
      pad_random(output, input)
    end)
  end

  def pad_random(output, input) do
    no = Enum.random(0..7)

    pad_list()
    |> Enum.at(no)
    |> then(&pad_led(output, deck1(), &1, led_on()))

    ret = midi_in(input)
    pag_all_off(output)
    (ret == no)
    |> IO.inspect()
  end

  def pag_all_off(output) do
    pad_list()
    |> Enum.map(fn x ->
      pad_led(output, deck1(), x, led_off())
    end)
  end

  def midi_in(input) do
    receive do
      {^input, []} ->
        midi_in(input)

      {^input, [{{_, _, 0}, _}]} ->
        midi_in(input)

      {^input, [{{_, no, 127}, _}]} ->
        Process.sleep(500)
        no

      _ ->
        nil
    after
      500 ->
        nil
    end
  end
end
