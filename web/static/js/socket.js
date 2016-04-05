
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {guardian_token: window.userToken}})
socket.connect();

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {guardian_token: window.userToken});
let chatInput = $("#chat-input");
let messagesContainer = $("#messages");

chatInput.on("keypress", event => {
  if (event.keyCode === 13) {
    channel.push("new_msg", {body: chatInput.val()});
    chatInput.val("")
  }
});

channel.on("new_msg", payload => {
  messagesContainer.append(`<br/>${payload.sender}: ${payload.message}`);
});

function appendChatMessage(msg) {
  messagesContainer.append(`<br/>${msg.sender}: ${msg.message}`);
}

channel.join()
    .receive("ok", resp => {
      console.log("Joined successfully", resp)

      let history = resp.history;
      history.forEach(appendChatMessage);

    })
    .receive("error", resp => {
      console.log("Unable to join", resp)
    });

export default socket
