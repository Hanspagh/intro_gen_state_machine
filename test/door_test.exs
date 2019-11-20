defmodule DoorTest do
  alias GSM.Door
  use ExUnit.Case
  @code [1, 2, 3] # code to open door
  @open_time 1000

  test "happy path" do
    {:ok, door} = Door.start_link({@code})
    assert Door.get_state(door) == :locked
    door |> Door.button(1)
    assert Door.get_state(door) == :locked
    door |> Door.button(2)
    assert Door.get_state(door) == :locked
    door |> Door.button(3)
    assert Door.get_state(door) == :open
    :timer.sleep(@open_time)
    assert Door.get_state(door) == :locked
  end

  test "sad path" do
    {:ok, door} = Door.start_link({@code})
    assert Door.get_state(door) == :locked
    door |> Door.button(1)
    assert Door.get_state(door) == :locked
    door |> Door.button(3)
    assert Door.get_state(door) == :locked
    door |> Door.button(2)
    assert Door.get_state(door) == :locked
  end

  test "push button when open" do
    {:ok, door} = Door.start_link({@code})
    assert Door.get_state(door) == :locked
    door |> Door.button(1)
    assert Door.get_state(door) == :locked
    door |> Door.button(2)
    assert Door.get_state(door) == :locked
    door |> Door.button(3)
    assert Door.get_state(door) == :open

    door |> Door.button(1)
    
    :timer.sleep(@open_time)
    assert Door.get_state(door) == :locked
  end
end
