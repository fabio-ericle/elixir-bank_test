defmodule BankTestTest do
  use ExUnit.Case
  doctest BankTest

  test "greets the world" do
    assert BankTest.hello() == :world
  end
end
