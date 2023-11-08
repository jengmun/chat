// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

const hooks = {};

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: hooks,
});

hooks.getUsername = {
  mounted() {
    const result = localStorage.getItem("username");

    this.pushEvent("get_username", {
      username: result,
    });
  },
};
// combine w set storage
hooks.getRooms = {
  mounted() {
    const result = JSON.parse(localStorage.getItem("rooms"));

    this.pushEvent("get_rooms", {
      rooms: result,
    });
  },
};

hooks.setStorage = {
  mounted() {
    window.addEventListener("phx:session-storage", (event) => {
      const { type, data } = event.detail;

      switch (type) {
        case "username":
          Object.keys(data).forEach((key) => {
            localStorage.setItem(key, data[key]);
          });
          window.location.href = "/chat";
          break;
        case "join_room":
          const storedRooms = JSON.parse(localStorage.getItem("rooms")) || [];

          if (!storedRooms.find((storedRoom) => storedRoom === data.room)) {
            const updatedStoredRooms = [data.room, ...storedRooms];
            localStorage.setItem("rooms", JSON.stringify(updatedStoredRooms));
          }

          break;

        default:
          break;
      }
    });
  },
};

hooks.autoScroll = {
  mounted() {
    window.addEventListener("phx:auto-scroll", () => {
      const container = document.getElementById("autoScroll");
      container.scrollTop = container.scrollHeight;
    });
  },
};

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
