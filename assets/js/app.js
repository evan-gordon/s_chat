// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Dependencies:
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import css from '../css/app.scss';

// Local files
import { player, initYTPlayer } from "./youtube.js"
import { autoscroll } from "./helpers.js"
import socket from "./socket"

let ul = document.getElementById('msg-list');        // list of messages.
let name = document.getElementById('name');          // name of message sender
let msg = document.getElementById('msg');            // message input field
let vc = document.getElementById('video-container');
let edit_button = document.getElementById("save-button");

//setup websocket
var channel = socket.channel('room:lobby', {}); // connect to chat "room"
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on('shout', function (payload) { // listen to the 'shout' event
  console.log(payload)
  switch (payload["type"]) {
    case "chat":
      var li = document.createElement("li"); // create new list item DOM element
      li.innerHTML = '<b>' + payload.name + '</b>: ' + payload.message; // set li contents
      ul.appendChild(li);                    // append to list
      autoscroll();
      break;
    case "video-player":
      initYTPlayer(vc, payload["hash"], channel);
      break;
    case "start-player":
      console.log("received start-video")
      console.log(player);
      if (player != null) {
        player.playVideo();
      }
      else {
        console.log("cannot start video, does not exist.");
      }
    default:
      null
  }
});

// "listen" for the [Enter] keypress event to send a message:
msg.addEventListener('keypress', function (event) {
  if (event.keyCode == 13 && msg.value.length > 0) { // don't sent empty msg.
    channel.push('shout', { // send the message to the server on "shout" channel
      message: msg.value    // get message text (value) from msg input field.
    });
    msg.value = '';         // reset the message input field for next message.
  }
});

window.addEventListener("beforeunload", function (e) {
  channel.push("leave", { reason: "bye" });
});

edit_button.addEventListener("click", function (e) {
  channel.push("edit:name", { name: name.value });
});

edit_button.addEventListener("keypress", function (e) {
  if (event.keyCode == 13 && edit_button.value.length > 0) {
    channel.push("edit:name", { name: name.value });
  }
});