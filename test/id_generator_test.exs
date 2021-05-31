defmodule IdGeneratorTest do
  use ExUnit.Case
  doctest IdGenerator

  test "greets the world" do
    assert IdGenerator.hello() == :world
  end
end
