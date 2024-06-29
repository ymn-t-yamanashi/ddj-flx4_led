defmodule HogeTest do
  use ExUnit.Case
  doctest Hoge

  test "greets the world" do
     Hoge.hello()
  end
end
