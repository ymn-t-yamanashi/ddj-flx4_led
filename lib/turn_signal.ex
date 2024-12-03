defmodule TurnSignal do
  @moduledoc """
  Documentation for `TurnSignal`.
  """
  import Ddj

  @doc """
  左側のウインカーの光るリスト
  """
  def deck1_signal do
    [
      {pad4(), pad8()},
      {pad3(), pad7()},
      {pad2(), pad6()},
      {pad1(), pad5()}
    ]
  end

  @doc """
  右側のウインカーの光るリスト
  """
  def deck2_signal do
    # 左側と逆になる
    deck1_signal()
    |> Enum.reverse()
  end

  def start() do
    output = open()

    # ウインカーは5回
    1..5
    |> Enum.each(fn _ -> task_deck(output) end)

    close(output)
  end

  @doc """
  左右ウインカー1回分
  """
  def task_deck(output) do
    # 非同期で左ウインカーを処理
    task_deck1 =
      Task.async(fn ->
        deck1_signal()
        |> signal_process(deck1(), output)
      end)

    # 非同期で右ウインカーを処理
    task_deck2 =
      Task.async(fn ->
        deck2_signal()
        |> signal_process(deck2(), output)
      end)

    # 左右のウインカーを処理が終わるまで待機
    Task.await(task_deck1)
    Task.await(task_deck2)
  end

  @doc """
  片方のウインカーを処理
  """
  def signal_process(pattern, deck, output) do
    pattern
    |> Enum.each(&signal_on(&1, deck, output))

    Process.sleep(300)

    pattern
    |> Enum.each(&signal_off(&1, deck, output))

    Process.sleep(300)
  end

  @doc """
  上段、下段のPadの表示/非表示
  """
  def signal({pad_up, pad_down}, deck, led_sw, output) do
    pad_led(output, deck, pad_up, led_sw)
    pad_led(output, deck, pad_down, led_sw)
  end

  @doc """
  上段、下段のPadの表示
  表示後100ミリ秒待つ
  """
  def signal_on({pad_up, pad_down}, deck, output) do
    signal({pad_up, pad_down}, deck, led_on(), output)
    Process.sleep(100)
  end

  @doc """
  上段、下段のPadの非表示
  """
  def signal_off({pad_up, pad_down}, deck, output),
    do: signal({pad_up, pad_down}, deck, led_off(), output)
end
