defmodule WebApiTest do
  use ExUnit.Case
  doctest WebApi

  test "greets the world" do
    assert WebApi.hello() == :world
  end
end
