defmodule WhyDidRecompileTest do
  use ExUnit.Case
  doctest WhyDidRecompile

  test "greets the world" do
    assert WhyDidRecompile.hello() == :world
  end
end
