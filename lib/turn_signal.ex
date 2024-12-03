defmodule TurnSignal do
  @moduledoc """
  Documentation for `TurnSignal`.
  """
  import Ddj

  def deck1_signal do
    [
      {pad4(), pad8()},
      {pad3(), pad7()},
      {pad2(), pad6()},
      {pad1(), pad5()}
    ]
  end

  def deck2_signal do
    deck1_signal()
    |> Enum.reverse()
  end

  def start() do
    output = open()

    deck1_signal()
    |> signal_process(deck1(), output)

    close(output)
  end

  def signal_process(pattern, deck, output) do
    pattern
    |> Enum.each(&signal_on(&1, deck, output))

    Process.sleep(300)

    pattern
    |> Enum.each(&signal_off(&1, deck, output))
  end

  def signal({pad_up, pad_down}, deck, led_sw, output) do
    pad_led(output, deck, pad_up, led_sw)
    pad_led(output, deck, pad_down, led_sw)
  end

  def signal_on({pad_up, pad_down}, deck, output) do
    signal({pad_up, pad_down}, deck, led_on(), output)
    Process.sleep(100)
  end

  def signal_off({pad_up, pad_down}, deck, output),
    do: signal({pad_up, pad_down}, deck, led_off(), output)
end
