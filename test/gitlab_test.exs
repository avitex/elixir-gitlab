defmodule GitlabTest do
  use ExUnit.Case

  doctest Gitlab

  test "can create a new client" do
    assert match?(%Tesla.Client{}, Gitlab.Client.new())
  end
end
