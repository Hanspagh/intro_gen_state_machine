defmodule GSM.Door do
  use GenStateMachine
  @unlock_time 10000


  ### Client API

  def start_link({code}) do
    data = reset_remaining(code)
    GenStateMachine.start_link(__MODULE__, {:locked, data})
  end

  def button(pid, digit) do
    GenStateMachine.cast(pid, {:button, digit})
  end

  def get_state(pid) do
    GenStateMachine.call(pid, :get_state)
  end



  ### Server API
  def handle_event({:call, from}, :get_state, state, data) do
    {:next_state, state, data, [{:reply, from, state}]}
  end

  def handle_event(:cast, {:button, digit}, :locked, %{remaining: remaining, code: code} = data) do
    IO.puts "Pressed #{digit}"
    case remaining do
      [^digit] ->
        IO.puts "Correct code.  Unlocked for #{@unlock_time}"
        actions = [{{:timeout, :generic}, @unlock_time, :lock}]
        {:next_state, :open, reset_remaining(code), actions}
      [^digit | rest]  ->
        IO.puts "Correct digit but not yet complete."
        {:next_state, :locked, %{data | remaining: rest}}
      _ ->
        IO.puts "Wrong digit, locking."
        {:keep_state, reset_remaining(code)}
      end
  end

  def handle_event(:cast, {:button, _digit}, :open, _data) do
    :keep_state_and_data
  end

  def handle_event({:timeout, :generic}, :lock, :open, data) do
    IO.puts "timeout expired, locking door"
    {:next_state, :locked, data}
  end

  ## Helpers

  def reset_remaining(code) do
    %{code: code, remaining: code}
  end




end
