export function autoscroll() {
    var chatbox = document.getElementById("msg-list");
    chatbox.scrollTop = chatbox.scrollHeight;
  }

export function generate_uid() {
  let id = Math.floor(Math.random() * 9999 + 1);
  return 'penguin_' + id.toString();
}