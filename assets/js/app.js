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
import css from '../css/app.css';
import "phoenix_html"

// Local files
import { autoscroll } from "./helpers.js"
import socket from "./socket"

var channel = socket.channel('room:lobby', {}); // connect to chat "room"
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })



channel.on('shout', function (payload) { // listen to the 'shout' event
  var li = document.createElement("li"); // create new list item DOM element
  var name = payload.name;    // get name from payload or set default
  li.innerHTML = '<b>' + name + '</b>: ' + payload.message; // set li contents
  ul.appendChild(li);                    // append to list
  autoscroll();
});

//channel.join(); // join the channel.

let ul = document.getElementById('msg-list');        // list of messages.
let name = document.getElementById('name');          // name of message sender
let msg = document.getElementById('msg');            // message input field

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
  channel.push("leave", { reason: "bye"});
});

let edit_button = document.getElementById("save-button");

edit_button.addEventListener("click", function (e) {
  channel.push("edit:name", {name: name.value});
});

edit_button.addEventListener("keypress", function (e) {
  if(event.keyCode == 13 && edit_button.value.length > 0) {
    channel.push("edit:name", {name: name.value});
  }
});