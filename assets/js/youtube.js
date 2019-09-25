export var player = null;

export function initYTPlayer(containerElement, videoID, channel) {
  loadYTPlayerApi();
  createYTIframe(containerElement, videoID);
  createYTPlayer(channel);
}

function loadYTPlayerApi() {
  var tag = document.createElement("script");
  tag.src = "https://www.youtube.com/iframe_api";
  tag.async = "";
  var firstScriptTag = document.getElementsByTagName("script")[0];
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
}

function createYTIframe(containerElement, videoID) {
  console.log("adding youtube video to page");
  var iframe = document.createElement("iframe");
  iframe.id = "video-player";
  iframe.src = "https://www.youtube.com/embed/" + videoID + "?enablejsapi=1&mute=1";
  iframe.frameBorder = "0";
  iframe.allow = "autoplay; encrypted-media; picture-in-picture";
  containerElement.innerHTML = ''; // reset video container
  containerElement.appendChild(iframe);
}

function createYTPlayer(channel) {
  window.onPlayerStateChange = function (event) { }

  window.onYouTubeIframeAPIReady = function () {
    console.log("player ready");
    player = new YT.Player("video-player", {
      events: {
        'onReady': onPlayerReady,
        "onStateChange": onPlayerStateChange
      }
    });
    console.log(player);
  }

  window.onPlayerReady = function (event) {
    //change to wait for everybody ready
    channel.push("watch", {});
    //event.target.playVideo();
  }

  window.stopVideo = function () {
    player.stopVideo();
  }
}