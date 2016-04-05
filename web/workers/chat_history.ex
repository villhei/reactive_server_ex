defmodule ReactiveServer.ChatHistory do
  @moduledoc false
  
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  defp get_history(state, chat_name) do
    history = state |> Map.get(chat_name, [])
  end

  # Server callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get_history, chat_name}, from, state) do
    history = get_history(state, chat_name)
    {:reply, {:ok, history}, state}
  end

  def handle_cast({:msg, {chat_name, sender, message}}, state) do
    history = get_history(state, chat_name)
    new_history = [%{:sender => sender, :message => message}] ++ history
    {:noreply, state |> Map.put(chat_name, new_history)}
  end

  def handle_cast(n, state) do
  IO.puts("unknown")
    IO.inspect(n)
    {:noreply, state}
  end
end