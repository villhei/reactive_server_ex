defmodule ReactiveServer.RoomChannel do
  use Phoenix.Channel
  import Guardian.Phoenix.Socket
  import HtmlSanitizeEx

  def join("room:lobby", %{"guardian_token" => token}, socket) do
      case sign_in(socket, token) do
        {:ok, authed_socket, _guardian_params} ->
            {:ok, history} = GenServer.call(ReactiveServer.ChatHistory, {:get_history, "lobby"})
          {:ok, %{message: "Joined", history: history}, authed_socket}
        {:error, reason} ->
         { :error,  %{reason: :authentication_failed}}
      end
  end

  def join(_room, _params, _socket) do
   { :error,  %{reason: :authentication_required}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    user = current_resource(socket)
    message = strip_tags(body)
    sender = strip_tags(user.displayname)

    GenServer.cast(ReactiveServer.ChatHistory, {:msg, {"lobby", sender, message}})
    socket |>
        broadcast!("new_msg", %{message: message, sender: sender})
    {:noreply, socket}
  end

  def handle_guardian_auth_failure(reason), do: { :error, %{ error: reason } }

end